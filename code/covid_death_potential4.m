function tt = covid_death_potential4(fac,deathVE)
deathVE = IEdefault('deathVE',[0.02 0.08]);
fac = IEdefault('fac',[2/3,1]);
cd ~/covid-19-israel-matlab/data/Israel
load vacc

jf=java.text.DecimalFormat;
json = urlread('https://datadashboardapi.health.gov.il/api/queries/vaccinationsPerAge');
json = jsondecode(json);
tv = struct2table(json);

json = urlread('https://datadashboardapi.health.gov.il/api/queries/infectedByPeriodAndAgeAndGender');
json = jsondecode(json);
conf = nan(10,1);
for ii = 1:length(json)
    if contains(json{ii}.period,'קורונה')
        idx = str2num(json{ii}.section(1))+1;
        conf(idx,1) = json{ii}.female.amount + json{ii}.male.amount;
%         disp(idx)
    end
end
% ti = struct2table(json);

% population0 = [sum(vacc.pop1000(1:2))*1000;vacc.pop1000(3:8)*1000;vacc.pop1000(9)*1000];
population = [2777000*1.02+591000;1318000;1206000;1111000;875000;749000;531000;308000];
vaccinated1 = [tv.vaccinated_first_dose(1);tv.vaccinated_first_dose(2:7);sum(tv.vaccinated_first_dose(8:9))];
% confirmed = [sum(sum(ti{1:2,2:3}));sum(ti{3:8,2:3},2);sum(sum(ti{9:10,2:3}))];
confirmed = [conf(1)+conf(2);conf(3:8);conf(9)+conf(10)];
age = vacc.age(2:end);
age{1} = '0-20';
ifr = [0.00002;0.0001;0.0002;0.001;0.002;0.01;0.045;0.15];
ifr(1) = 1/140000;
tt = table(age,population,confirmed,vaccinated1,ifr);

hidden = [2.5,1]; % for every confirmed there is another hidden 
notConf = population-confirmed;
vaccAndConf = round((confirmed.*hidden./notConf) .* (vaccinated1./notConf) .* notConf);
confNotVax = confirmed*hidden-vaccAndConf;
y = population-vaccinated1-confirmed-confNotVax;

% fac = 1.3;
y = y.*[ifr*fac(1),ifr*fac(2)];
y(y < 0) = 0;
y(end+1,:) = sum(y);
Hasinut = round(100*sum((vaccinated1+confirmed+confNotVax))./sum(population));
if Hasinut(1) == Hasinut(2)
    Hasinut = [str(Hasinut(1)),'%'];
else
    Hasinut = [str(min(Hasinut)),'%',' עד ',str(max(Hasinut)),'%'];
end
%%
figure('position',[100,100,1000,650]);
h = bar(y);
ylim([5 max(max(y))*1.5])
set(gca, 'YScale', 'log')
grid on
text((1:9)-0.35,y(:,1)*1.25,str(round(y(:,1))),'Color',h(1).FaceColor)
text((1:9),y(:,2)*1.25,str(round(y(:,2))),'Color',h(2).FaceColor)
% text((1:9),y(:,3)*1.25,str(round(y(:,3))),'Color',h(3).FaceColor)

set(gca,'XTickLabel',[age;{'סה"כ'}],'fontsize',13)
set(gcf,'Color','w')
ylabel('תמותה')
% xlabel('שכבת גיל')
legend(['IFR x ',str(round(fac(1),2)),', על כל מאומת יש עוד 2.5 נדבקים שלא התגלו'],...
    ['IFR x ',str(fac(2)),',                על כל מאומת יש נדבק 1 שלא התגלה'],'location','northwest')
title({'פוטנציאל התמותה בקרב מי שלא נדבק או חוסן',['החסינות כרגע ',Hasinut]})

for iAge = 1:length(ifr)
    txt{iAge,1} = ['1:',char(jf.format(round(1./(ifr(iAge)*fac(1)))))];
    txt{iAge,2} = ['1:',char(jf.format(round(1./(ifr(iAge)*fac(2)))))];
end

text((1:8)-0.25,repmat(3,1,8),txt(:,1),'Color',h(1).FaceColor)
text((1:8)-0.25,repmat(2.5,1,8),txt(:,2),'Color',h(2).FaceColor)
text(0.3,4,'גיל','FontSize',13)
text(0.3,3,'IFR','Color',h(1).FaceColor)
text(0.3,2.5,'IFR','Color',h(2).FaceColor)


%% deaths for vaccinated / recovered

yy = min(tt.vaccinated1+tt.confirmed,population);
% yy = tt.vaccinated1+tt.confirmed;
yy = round(yy.*[ifr*deathVE(1),ifr*deathVE(2)]);
yy(yy < 0) = 0;
yy(end+1,:) = sum(yy);
%%
figure('position',[100,100,1000,650]);
h = bar(yy);
ylim([0.1 max(max(yy))*1.75])
set(gca, 'YScale', 'log')
grid on
text((1:9)-0.35,yy(:,1)*1.25,str(round(yy(:,1))),'Color',h(1).FaceColor)
text((1:9),yy(:,2)*1.25,str(round(yy(:,2))),'Color',h(2).FaceColor)
% text((1:9),y(:,3)*1.25,str(round(y(:,3))),'Color',h(3).FaceColor)

set(gca,'XTickLabel',[age;{'סה"כ'}],'fontsize',13)
set(gcf,'Color','w')
ylabel('תמותה')
% xlabel('שכבת גיל')
legend(['IFR x ',str(deathVE(1)*100),'%'],['IFR x ',str(deathVE(2)*100),'%'],'location','northwest')
title(['פוטנציאל התמותה בקרב המחוסנים והמחלימים, לפי אחוז פגיעות מקל (',str(deathVE(1)*100),'%) ומחמיר (',str(deathVE(2)*100),'%)'])

for iAge = 1:length(ifr)
    txtx{iAge,1} = ['1:',char(jf.format(round(1./(ifr(iAge)*deathVE(1)))))];
    txtx{iAge,2} = ['1:',char(jf.format(round(1./(ifr(iAge)*deathVE(2)))))];
end

% strrep(cellstr([repmat('1/',8,1),num2str(round(1./(ifr*0.01)))]),' ','')

text((1:8)-0.25,repmat(0.05,1,8),txtx(:,1),'Color',h(1).FaceColor)
text((1:8)-0.25,repmat(0.035,1,8),txtx(:,2),'Color',h(2).FaceColor)
text(0.3,0.07,'גיל','FontSize',13)
text(0.3,0.05,'IFR','Color',h(1).FaceColor)
text(0.3,0.035,'IFR','Color',h(2).FaceColor)

tt.death_unprotected_low = round(y(1:end-1,1));
tt.death_unprotected_high = round(y(1:end-1,2));
tt.death_protected_low = round(yy(1:end-1,1));
tt.death_protected_high = round(yy(1:end-1,2));
writetable(tt,'death_potential.csv','Delimiter',',','WriteVariableNames',true)

