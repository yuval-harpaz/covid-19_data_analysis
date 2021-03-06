cd ~/covid-19-israel-matlab/data/Israel

txt = urlread('https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/ages_dists.csv');
txt = txt(find(ismember(txt,newline),1)+1:end);
fid = fopen('tmp.csv','w');
fwrite(fid,txt);
fclose(fid);
ag = readtable('tmp.csv');
agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
casesYOday = [sum(ag{:,[2:7,12:17]},2),sum(ag{:,[8:11,18:21]},2)];
%%
yyy0 = movmean(diff(casesYOday)./datenum(diff(agDate)),[11 11],'omitnan');
yyy0 = movmean(yyy0,[11 11],'omitnan');

figure;
yyaxis left
plot(agDate(2:end),yyy0)
ylabel('מאומתים')
yyaxis right
plot(agDate(2:end),yyy0(:,2)./yyy0(:,1)*100)
ylabel('שיאור המאומתים המבוגרים')
ax = gca;
ax.YRuler.Exponent = 0;
ylim([4 20])
set(gca,'ytick',0:2:24)
hold on
last24i = find(agDate < agDate(end)-1,1,'last');
last24 = diff(casesYOday([last24i,end],:));
plot(agDate(end),last24(2)./last24(1)*100,'.')
legend('מתחת 60','מעל 60','שיעור המבוגרים','location','northwest')
title('מאומתים לפי גיל')
grid on
grid minor
xtickformat('MMM')
set(gcf,'Color','w')
%%
col = [0.259 0.525 0.961;0.063 0.616 0.345;0.961 0.706 0.4;0.988 0.431 0.016;0.863 0.267 0.216];


clear yy;
for ii = 1:5
    idx = 1+(ii*2-1:ii*2);
    yy(1:length(agDate),ii) = sum(ag{:,idx},2);
    disp(idx)
end
yyy = movmean(diff(yy)./datenum(diff(agDate)),[11 11],'omitnan');
yyy = [cumsum(yyy,2);zeros(size(yyy))];
xxx = [agDate(2:end);flipud(agDate(2:end))];

figure;
subplot(2,1,1)
for ii = 1:5
    fill(xxx,yyy(:,6-ii),col(6-ii,:),'linestyle','none')
    hold on
end
% plot(agDate(2:end),yyy)
legend('80+','60-80','40-60','20-40','0-20','location','northwest');
set(gcf,'Color','w')
ax = gca;
ax.YRuler.Exponent = 0;
xtickformat('MMM')
xlim(agDate([2,end]))
grid on
title('מאומתים לפי גיל')
set(gca, 'layer', 'top');

yyy1 = yyy./yyy(:,5)*100;
yyy1(isnan(yyy1)) = 0;
subplot(2,1,2)
for ii = 1:5
    fill(xxx,yyy1(:,6-ii),col(6-ii,:),'linestyle','none')
    hold on
end
% legend('80+','60-80','40-60','20-40','0-20','location','northwest');
set(gcf,'Color','w')
ax = gca;
ax.YRuler.Exponent = 0;
xtickformat('MMM')
xlim(agDate([2,end]))
grid on
title('מאומתים לפי גיל (%)')
set(gca, 'layer', 'top');
