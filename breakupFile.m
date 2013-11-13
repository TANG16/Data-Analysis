function breakupFile(file,MBperFile,unixcmdspath)

if(nargin==2)
    unixcmdspath='C:\cygwin\bin';
end

bytesPerFile=MBperFile*1000000;
[filepath,filename,fileext]=fileparts(file);

header_file = [file '_header'];
data_file = [file '_data'];

path= getenv('PATH');
if(isempty(strfind(path,unixcmdspath)))
    path = [unixcmdspath ';' path];
    setenv('PATH',path);
end

[~,grep_output]=unix(['grep -n -x ''#begin-data'' ' file]);
n_line_beg_data_cell=regexp(grep_output,'(\d+):#begin-data','tokens');
n_line_beg_data_str=n_line_beg_data_cell{1}{1};

unix(['head -' n_line_beg_data_str ' ' file ' > ' header_file]);

unix(['tail -n +' num2str(str2double(n_line_beg_data_str)+1) ' ' file ' | head -n -1 > ' data_file]);

[~,nLinesTotWcOutput]=unix(['wc -l ' data_file]);
nLinesTotCell=regexp(nLinesTotWcOutput,['(\d+) ' data_file],'tokens');
nLinesTotNum=str2double(nLinesTotCell{1}{1});

[~,nBytesTotWcOutput]=unix(['wc -c ' data_file]);
nBytesTotCell=regexp(nBytesTotWcOutput,['(\d+) ' data_file],'tokens');
nBytesTotNum=str2double(nBytesTotCell{1}{1});

linesPerFileNum=floor((nLinesTotNum/nBytesTotNum) * bytesPerFile);
linesPerFileStr=num2str(linesPerFileNum);

i=1;
i_n_lines_data_file_tail=nLinesTotNum;
while(i_n_lines_data_file_tail > 0)
    iStr=num2str(i);
    i_data_file_tail=[data_file '_tail_' iStr];
    i_no_end_data_file=[file '_no_end_data_' iStr];
    i_file=fullfile(filepath,[[filename '_' iStr] fileext]);
    
    % commented out code didn't work because standard output didn't have enough
    % memory
    % unix(['tail -' num2str(nLinesTotNum-(i-1)*linesPerFileNum) ' ' data_file
    % ' | head -' linesPerFileStr ' | cat ' header_file ' - > ' i_no_end_data_file])
    unix(['tail -' num2str(nLinesTotNum-(i-1)*linesPerFileNum) ' ' data_file ' > ' i_data_file_tail]);
    unix(['head -' linesPerFileStr ' ' i_data_file_tail ' | cat ' header_file ' - > ' i_no_end_data_file]);
    unix(['echo #end-data | cat ' i_no_end_data_file ' - > ' i_file]);
    
    i_n_lines_data_file_tail=nLinesTotNum-i*linesPerFileNum;
    
    delete(i_data_file_tail,i_no_end_data_file);
    
    i=i+1;
end

delete(header_file,data_file);

end