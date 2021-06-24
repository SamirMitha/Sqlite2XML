%Samir Mitha - (c) 2021
%sqlite2xsd(db_file, save_file)
%Converts and sqlite database to XSD.
% Parameters
% ----------
% db_file: path to .db file
% save_file: save file name as .xsd
%
% Example
% -------
% sqlite2xml('home/Documents/sqlite/database.db', 'home/Documents/XML/output.xsd')
% Types will need to be changed and foreign keys will need to be added.

function [] = sqlite2sd(db_file, save_file)
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
    fk_idx = [];
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
    %         if contains(split_statement(i), "fk")
    %             fk_idx(j, i) = true;
    %         else
    %             fk_idx(j, i) = false;
    %         end
            if (i == 1)
                placeholder = split(split_statement(i), "(");
                split_statement(1) = " " + placeholder(2);
            end
            placeholder = split(split_statement(i), " ");
            attributes(j, i) = placeholder(2);
        end
    end

    %% Determining Foreign Keys
    % fk_idx = logical(fk_idx);
    % foreign_keys = attributes(fk_idx);
    % incompatible with foreign keys since relationships cannot be determined
    % easily

    %% Making XSD
    % header
    fileID = fopen(save_file, 'w');
    fprintf(fileID,'<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">\n\n');
    % creating primary keys
    key_open = fprintf(fileID,'\t<xs:element name="DatabaseData" type="DatabaseType">\n\n');

    for i = 1:size(tables,1)
        entry_open = fprintf(fileID,'\t\t<xs:key name="%sKey">\n', tables(i));
        selector = fprintf(fileID,'\t\t\t<xs:selector xpath="%s"/>\n', tables(i));
        field = fprintf(fileID,'\t\t\t<xs:field xpath="%s"/>\n', attributes(i,1));
        entry_close = fprintf(fileID,'\t\t</xs:key>\n\n');
    end

    key_close = fprintf(fileID,'\t</xs:element>\n\n');

    % creating complex type for DatabaseType
    fprintf(fileID,'\t<xs:complexType name="DatabaseType">\n');
    fprintf(fileID,'\t\t<xs:sequence>\n');

    for i = 1:size(tables,1)
        fprintf(fileID,'\t\t\t<xs:element ref="%s" minOccurs="0" maxOccurs="unbounded"/>\n', tables(i));
    end

    fprintf(fileID,'\t\t</xs:sequence>\n');
    fprintf(fileID,'\t</xs:complexType>\n\n');

    % creating element for tables
    for i = 1:size(tables,1)
        fprintf(fileID,'\t<xs:element name="%s">\n', tables(i));
        fprintf(fileID,'\t\t<xs:complexType>\n');
        fprintf(fileID,'\t\t\t<xs:sequence>\n');
        for j = 1:size(rmmissing(attributes(i,:)), 2)
            fprintf(fileID,'\t\t\t\t<xs:element name="%s" type="xs:string"/>\n', attributes(i,j));
        end
        fprintf(fileID,'\t\t\t</xs:sequence>\n');
        fprintf(fileID,'\t\t</xs:complexType>\n');
        fprintf(fileID,'\t</xs:element>\n\n');
    end

    fprintf(fileID,'</xs:schema>');
    fclose(fileID);
end