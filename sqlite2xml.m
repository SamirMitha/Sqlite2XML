%Samir Mitha - (c) 2021
%sqlite2xml(db_file, save_file)
%Converts and sqlite database to XML.
% Parameters
% ----------
% db_file: path to .db file
% save_file: save file name as .xml
%
% Example
% -------
% sqlite2xml('home/Documents/sqlite/database.db', 'home/Documents/XML/output.xml')

function [] = sqlite2xml(db_file, save_file)
    conn = sqlite(db_file, 'readonly');

    db = fetch(conn, "SELECT * FROM sqlite_master where type='table';");
    num_of_tables = size(db,1);

    %% Determining Tables
    for i = 1:num_of_tables
        tables(i) = string(sprintf(db{i,3}));
    end

    tables = tables';
    tables(contains(tables, "sqlite_sequence")) = [];

    %% Determining Attributes
    for j = 1:size(tables, 1)
        statement = "SELECT * FROM sqlite_master WHERE tbl_name='" + tables(j) + "' AND type='table';";
        db = fetch(conn, statement);
        table_create = string(db{1,5});
        split_statement = split(table_create, {'TABLE', ','});
        split_statement(contains(split_statement, "CONSTRAINT")) = [];
        split_statement(contains(split_statement, "CREATE")) = [];

        for i = 1:size(split_statement,1)
    %         if contains(split_statement(i), "CONSTRAINT")
    %             split_statement(i) = replace(split_statement(i), "CONSTRAINT ", "");
    %         end
            if (i == 1)
                placeholder = split(split_statement(i), "(");
                split_statement(1) = " " + placeholder(2);
            end
            placeholder = split(split_statement(i), " ");
            attributes(j, i) = placeholder(2);
        end
    end

    %% Making XML
    % header
    fileID = fopen(save_file, 'w');
    fprintf(fileID,'<?xml version="1.0" encoding="UTF-8"?>\n<Database>\n\n');
    for i = 1:size(tables,1)
        % Sqlite to XML object
        statement = "SELECT * FROM '" + tables(i) + "';";
        db = fetch(conn, statement);
        entries = string(db);
        xml_object = cat(1, rmmissing(attributes(i,:)), entries);

        for k = 2:size(xml_object, 1)
            entry_open = fprintf(fileID,'\t<%s>\n', tables(i));
            for j = 1:size(xml_object, 2)
                entry = fprintf(fileID,'\t\t<%s>%s</%s>\n', xml_object(1,j), xml_object(k,j), xml_object(1,j));
            end
            entry_close = fprintf(fileID,'\t</%s>\n\n', tables(i));
        end
    end
    fprintf(fileID,'</Database>');
    fclose(fileID);
end