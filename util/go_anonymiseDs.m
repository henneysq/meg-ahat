function go_anonymiseDs(input,output)
% Note// input and output filenames must include filepaths

% Add path to CTF functions
ft_hastoolbox('ctf', 1);

fprintf('Anonymising dataset ******.ds: ');

hdr = readCTFds(input);
data = getCTFdata(hdr,[],[],'fT');

hdr_anon = hdr;

% Remove identifiable information
% RES4
hdr_anon.res4.data_time=' ';
hdr_anon.res4.data_date=' ';
hdr_anon.res4.nf_run_name=' ';
hdr_anon.res4.nf_instruments=' ';
hdr_anon.res4.nf_collect_descriptor=' ';
hdr_anon.res4.nf_subject_id=' ';
hdr_anon.res4.nf_operator=' ';
hdr_anon.res4.nf_sensorFileName=' ';

% INFODS - loop through all fields which say patient/procedure/dataset
for ii = 1:length(hdr_anon.infods);
    if ~isempty(strfind(hdr.infods(ii).name,'PATIENT'))
        hdr_anon.infods(ii).data = '';
        % the sex field requires a number, just set to 2
        if ~isempty(strfind(hdr.infods(ii).name,'SEX'))
            hdr_anon.infods(ii).data = 2;
        end
    end
end
for ii = 1:length(hdr_anon.infods);
    if ~isempty(strfind(hdr.infods(ii).name,'PROCEDURE'))
        if hdr_anon.infods(ii).type == 10;
        hdr_anon.infods(ii).data = '';
        end
    end
end
for ii = 1:length(hdr_anon.infods);
    if ~isempty(strfind(hdr.infods(ii).name,'DATASET'))
        if hdr_anon.infods(ii).type == 10;
        hdr_anon.infods(ii).data = '';
        end
    end
end

% Remove dataset history too to make sure scan date is gone.
hdr_anon.hist = 'REDACTED';
hdr_anon.processing = 'REDACTED';

% Write out file with new anonymised header file
writeCTFds([output],hdr_anon,data,'fT');

fprintf('COMPLETE\n');