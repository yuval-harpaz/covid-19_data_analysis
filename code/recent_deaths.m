
json = urlread('https://data.gov.il/api/3/action/datastore_search?resource_id=a2b2fceb-3334-44eb-b7b5-9327a573ea2c&limit=500000');
json = jsondecode(json);
death = json.result.records;
death = struct2table(death);
[~,msg] = system('wget -O tmp.csv https://raw.githubusercontent.com/erasta/CovidDataIsrael/3af0616918b216a7b29eacfc043c5750adb931c1/out/csv/moh_corona_deceased.csv');
%  death0 = readtable('/media/innereye/1T/Data/Untitled.csv');
death0 = readtable('tmp.csv');
row = nan(height(death0),1);
for ii = height(death0):-1:1
    ir = height(death);
    search = true;
    while search
        if isequal(death{ir,2:end},death0{ii,2:end})
            if ismember(row,ir)
                disp([str(ir),' already'])
            else
                row(ii,1) = ir;
                search = false;
            end
        end
        ir = ir-1;
        if ir == 0;
            search = false;
        end
    end
    disp(ii)
end

death1 = death;
death1(row(~isnan(row)),:) = [];
death0(isnan(row),:) = [];

ttd = death0.Time_between_positive_and_death;
ttd(ismember(ttd,'NULL')) = [];
ttd0 = hist(cellfun(@str2num, ttd),-2:140);
median(cellfun(@str2num, ttd))
ttd = death1.Time_between_positive_and_death;
ttd(ismember(ttd,'NULL')) = [];
median(cellfun(@str2num, ttd))
ttd1 = hist(cellfun(@str2num, ttd),-2:140);
figure;
bar((-2:140)-0.2,100*tth0/sum(ttd0),'EdgeColor','none')
hold on
bar((-2:140)+0.2,100*tth1/sum(ttd1),'EdgeColor','none')
xlim([-2 25])
legend('עד ספט 25','מ ספט 25')
set(gca,'FontSize',13)
ylabel('הסיכוי לתמותה (%)')
grid on
title('יום הפטירה ביחס ליום קבלת תוצאה חיובית')


tth = death0.Time_between_positive_and_hospitalization;
tth(ismember(tth,'NULL')) = [];
tth0 = hist(cellfun(@str2num, tth),-2:140);
median(cellfun(@str2num, tth))
tth = death1.Time_between_positive_and_hospitalization;
tth(ismember(tth,'NULL')) = [];
median(cellfun(@str2num, tth))
tth1 = hist(cellfun(@str2num, tth),-2:140);
figure;
bar((-2:140)-0.2,100*tth0/sum(tth0),'EdgeColor','none')
hold on
bar((-2:140)+0.2,100*tth1/sum(tth1),'EdgeColor','none')

