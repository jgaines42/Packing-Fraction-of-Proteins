function []=  process_volume_output(PDB, folder1, num_atoms)
    edge_data = zeros(num_atoms, 100);
    vol_data = zeros(num_atoms, 100);

    for j = 1:100
        file_name = strcat(folder1,PDB, num2str(j), '.txt');
        inputFile = fopen(file_name);
        volumes_data  = textscan(inputFile, '%f %f %f');
        edge_data(:,j) =volumes_data{2};
        vol_data(:,j) = volumes_data{3};

        fclose(inputFile);
       
    end
    edge_data = max(edge_data,[],2);
    vol_data = mean(vol_data,2);
    
    f = fopen(strcat(folder1, PDB, '_vol.txt'),'w');
    for i = 1:num_atoms
            fprintf(f, '%d %f \n', edge_data(i), vol_data(i));
    end
    fclose(f);
    
end