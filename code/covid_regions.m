function covid_regions
cd ~/covid-19-israel-matlab/
threshold = 750; %plot results over this deaths per million

%% Whole countries
cellCount = 1;
[dataMatrix] = readCoronaData('deaths');
[~,date{cellCount},mergedData] = processCoronaData(dataMatrix);
date{cellCount} = date{cellCount}';
for iCou = 1:length(mergedData)
    mergedData{iCou,2}(isnan(mergedData{iCou,2})) = 0;
    mergedData{iCou,2}(mergedData{iCou,2} < 0) = 0;
end
popCou = readtable('data/population.csv','delimiter',',');
mergedData(~ismember(mergedData(:,1),popCou.Country_orDependency_),:) = [];
[~,idx] = ismember(mergedData(:,1),popCou.Country_orDependency_);
deceased{cellCount} = nan(length(date{cellCount}),length(idx));
for ii = 1:length(idx)
    deceased{cellCount}(:,ii) = mergedData{ii,2};
end
pop{cellCount} = popCou(idx,:);
country{cellCount} = pop{cellCount}{:,1};

%% NYC
cellCount = cellCount+1;
[date{cellCount,1},popNYC,nyc,nycp] = covid_nyc;
pop{cellCount,1} = table({'NYC_Confirmed';'NYC_Probable'},[popNYC;popNYC]);
deceased{cellCount,1} = [nyc,nycp];
country{cellCount,1} = repmat({'US'},size(pop{cellCount},1),1);
%% USA states
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_usa;
deceased{cellCount} = deceased{cellCount}{:,2:end}';
pop{cellCount}{:,1} = strrep(pop{cellCount}{:,1},'Georgia','Georgia US');
country{cellCount,1} = repmat({'US'},size(pop{cellCount},1),1);

%% spain
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_spain;
% deceased{cellCount} = deceased{cellCount}{:,2:end}';
country{cellCount} = repmat({'Spain'},size(pop{cellCount},1),1);

%% Italy
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_italy;
deceased{cellCount} = deceased{cellCount}{:,:};
country{cellCount} = repmat({'Italy'},size(pop{cellCount},1),1);

%% Brazil
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_brazil;
country{cellCount} = repmat({'Brazil'},size(pop{cellCount},1),1);
%% Ecuador
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_ecuador;
country{cellCount} = repmat({'Ecuador'},size(pop{cellCount},1),1);
%% Russia
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_russia;
country{cellCount} = repmat({'Russia'},size(pop{cellCount},1),1);
%% Mexico
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_mexico;
country{cellCount} = repmat({'Mexico'},size(pop{cellCount},1),1);
%% UK (London)
cellCount = cellCount+1;
[deceased{cellCount},pop{cellCount},date{cellCount}] = covid_uk;
country{cellCount} = repmat({'UK'},size(pop{cellCount},1),1);

%% save a table
badChar = {'P.A. ','';...
    '''','';...
    'ó','o';...
    'á','a';...
    'í','i';...
    'é','e';...
    'ã','a';...
    'ñ','n';...
    'ô','o';...
    '-',' ';...
    '(','';...
    ')','';...
    '*','';...
    '_',' '};
Date = {};
Region = {};
Country = {};
Population = [];
for ii = 1:length(date)
    iNaT = isnat(date{ii});
    date{ii}(iNaT) = [];
    deceased{ii}(iNaT,:) = [];
    Date =[Date;date{ii}];
    for iBad = 1:length(badChar)
        pop{ii}{:,1} = strrep(pop{ii}{:,1},badChar{iBad,1},badChar{iBad,2});
    end
    Region = [Region;pop{ii}{:,1}];
    Country = [Country;country{ii}];
    Population = [Population;pop{ii}{:,2}];
end

if length(Region) > length(unique(Region))
    error('Region is not unique');
end
Date = unique(Date);
for ii = 1:length(deceased)
    if size(pop{ii},1) ~= size(deceased{ii},2)
        error(['bad matrix size for',num2str(ii)])
    end
end
Date_ = cellstr(datestr(Date,'mmm_dd_yyyy'));
list = table(Country,Region,Population);
for ii = 1:length(Date)
    eval(['list.',Date_{ii},' = nan(length(Region),1);']);
end
for ii = 1:length(deceased)
    iDate = find(ismember(Date,date{ii}));
    iReg = ismember(Region,pop{ii}{:,1});
    list{iReg,iDate+3} = deceased{ii}';
end
ignore = find(Date > dateshift(datetime('now'),'start','day'),1);
if ~isempty(ignore)
    list(:,ignore+3:end) = [];
    Date(ignore:end) = [];
end
nanwritetable(list,'data/regions.csv');
%% sort 

listDate = datetime(strrep(list.Properties.VariableNames(4:end),'_','-'),'InputFormat','MMM-dd-yyyy');
y = list{:,4:end}'./list.Population'*10^6;
[~,order] = sort(nanmax(y),'descend');
y = y(:,order);
loc = list{order,2};
loc{ismember(loc,'New York')} = 'New York State';
iXtick = fliplr(length(listDate):-7:1);
nLines = find(nanmax(y) > threshold,1,'last');
%% plot
fig10 = figure('units', 'normalized', 'position',[0.1,0.1,0.5,0.7]);
for ii = 1:nLines
    notNan = ~isnan(y(:,ii));
    h(ii) = plot(listDate(notNan),y(notNan,ii));
    hold on
end
xlim(listDate([40,end]))
yt = max(max(y)):-max(max(y))/nLines:0;
grid on
box off
title({'worst COVID-19 places',['regions with more than ',num2str(threshold),' deaths per million']})
ylabel('Deaths per million')
set(gca,'fontsize',13,'XTick',listDate(iXtick),'position',[0.13 0.12 0.7 0.8])
set(gcf,'Color',[0.65 0.65 0.65],'InvertHardcopy', 'off')
xtickangle(90)
% col = reshape([h(1:7).Color],3,7)';
col = hsv(10);
country = list.Country(order(1:nLines));
countryU = unique(country);
colorIndex = mod((0:length(countryU)-1),length(col))+1;
[~,iCou] = ismember(country,countryU);
countryColor = col(colorIndex(iCou),:);
for ii = 1:nLines
    h(ii).Color = countryColor(ii,:);
    if iCou(ii)/2 ~= round(iCou(ii)/2)
        h(ii).LineStyle = '--';
    end
    text(listDate(end),yt(ii),loc{ii},'color',h(ii).Color);
end
for ic = 1:length(countryU)
    text(listDate(5),100+yt(1)-75*ic,countryU{ic},'color',col(colorIndex(ic),:))
end
isr = readtable('data/Israel/dashboard_timeseries.csv');
isr.CountDeath(isnan(isr.CountDeath)) = 0;
plot(isr.date,cumsum(isr.CountDeath)/9.2,'k')
text(listDate(5),100+yt(1)-75*(ic+1),'Israel','color',[0,0,0])
text(listDate(end-30),20+sum(isr.CountDeath)/9.2,['Israel (',str(round(sum(isr.CountDeath)/9.2)),')'],'color',[0,0,0])
%% save
saveas(fig10,'docs/worst_region.png')
