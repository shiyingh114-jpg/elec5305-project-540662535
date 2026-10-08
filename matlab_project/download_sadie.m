function download_sadie()
%DOWNLOAD_SADIE Reproduce the public measured H10 SOFA file used in this experiment.
% Dataset landing page and license: https://zenodo.org/records/10886409
root=fileparts(mfilename('fullpath'));
dirName=fullfile(root,'data','hrir'); if ~isfolder(dirName), mkdir(dirName); end
fileName='H10_48K_24bit_256tap_FIR_SOFA.sofa';
licenseFile=fullfile(dirName,'SADIE_II_LICENSE.txt');
if ~isfile(licenseFile)
    websave(licenseFile,'https://zenodo.org/records/10886409/files/LICENSE.txt?download=1', ...
        weboptions('Timeout',120));
end
if isfile(fullfile(dirName,fileName)), fprintf('SOFA file already exists.\n'); return; end
url='https://zenodo.org/records/10886409/files/H10_HRIR_SOFA.zip?download=1';
work=tempname; mkdir(work); cleanup=onCleanup(@()rmdir(work,'s'));
archive=fullfile(work,'H10_HRIR_SOFA.zip');
fprintf('Downloading measured SADIE II H10 archive (~9.6 MB).\n');
websave(archive,url,weboptions('Timeout',120));
unzip(archive,work);
source=fullfile(work,'H10_HRIR_SOFA',fileName);
assert(isfile(source),'Unexpected dataset archive layout.');
copyfile(source,fullfile(dirName,fileName));
fprintf('Saved %s\n',fullfile(dirName,fileName));
end
