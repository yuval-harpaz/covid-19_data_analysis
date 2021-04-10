function [agf, agDate] = covid_fix_age(ag,thr)
 % ag can be a table or char. options: '', 'deaths_','severe_'
if nargin == 0
    ag = 'deaths_';
end
if ~exist('thr','var')
    thr = [];
end
if isempty(thr)
    thr = -9; % error size to correct
end
% if ~ischar(ag) % options: '', 'deaths_','severe_'
%     error(['ag should be char(''',''' or ''','deaths_''',')'])
% end
% 
if ischar(ag)    
    % cd ~/covid-19-israel-matlab/data/Israel
    % dbv = readtable('deaths by vaccination status.xlsx');
    txt = urlread(['https://raw.githubusercontent.com/dancarmoz/israel_moh_covid_dashboard_data/master/',ag,'ages_dists.csv']);
    txt = txt(find(ismember(txt,newline),1)+1:end);
    fid = fopen('tmp.csv','w');
    fwrite(fid,txt);
    fclose(fid);
    ag = readtable('tmp.csv');
end
agDate = cellfun(@(x) datetime([x(1:10),' ',x(12:19)]),ag.UpdateTime);
dif = diff(ag{:,2:11});
agf = ag;
for col = 1:9
    idx = find(dif(:,col) < thr);
    if ~isempty(idx)
        for jdx = 1:length(idx)
            if dif(idx(jdx),col+1) > dif(idx(jdx),col)*(-1)
                agf{idx(jdx)+1:end,col+1} = agf{idx(jdx)+1:end,col+1}-dif(idx(jdx),col);
                agf{idx(jdx)+1:end,col+2} = agf{idx(jdx)+1:end,col+2}+dif(idx(jdx),col);
%             else
%                 disp('uncprrected minus deaths')
            end
        end
    end
end