function output_progress = collect_mtm_one_joint(config,...
        mtm_arm,...
        is_collision_checking,...
        is_collecting_data,...
        input_progress,...
        progress_increment)
    %  Author(s):  Hongbin LIN, Vincent Hui, Samuel Au
    %  Created on: 2018-10-05
    %  Copyright (c)  2018, The Chinese University of Hong Kong
    %  This software is provided "as is" under BSD License, with
    %  no warranty. The complete license can be found in LICENSE

    % Collect Torque data by positive direction

    if is_collision_checking
        current_progress = input_progress;
        % Only one direction need to be check while collsition checking
        collect_mtm_one_joint_with_one_dir(config,...
            mtm_arm,...
            config.neg_joint_range_list,...
            config.neg_data_path,...
            is_collision_checking,...
            is_collecting_data,...
            'positive',...
            current_progress,...
            progress_increment);
    else
        current_progress = input_progress;
        if config.is_pos_dir
            current_progress = collect_mtm_one_joint_with_one_dir(config,...
                                        mtm_arm,...
                                        config.pos_joint_range_list,...
                                        config.pos_data_path,...
                                        is_collision_checking,...
                                        is_collecting_data,...
                                        'positive',...
                                        current_progress,...
                                        progress_increment);
        end
        if config.is_neg_dir
            current_progress = collect_mtm_one_joint_with_one_dir(config,...
                                        mtm_arm,...
                                        config.neg_joint_range_list,...
                                        config.neg_data_path,...
                                        is_collision_checking,...
                                        is_collecting_data,...
                                        'negative',...
                                        current_progress,...
                                        progress_increment);
        end
        output_progress = current_progress;
    end
end

function output_progress = collect_mtm_one_joint_with_one_dir(config,...
        mtm_arm,...
        joint_range_list,...
        data_save_path,...
        is_collision_checking,...
        is_collecting_data,...
        dir_name,...
        input_progress,...
        one_data_progress_increment)
    %  Institute: The Chinese University of Hong Kong
    %  Author(s):  Hongbin LIN, Vincent Hui, Samuel Au
    %  Created on: 2018-10-05

    sample_num = config.sample_num;
    steady_time = config.steady_time;

    if is_collision_checking
        fprintf('Checking trajectory collision for joint %d in %s direction now..\n',...
            config.Train_Joint_No, dir_name);
        disp('If the MTM hits the environment, please hit E-Button to stop instantly!');
    end
    
    current_progress = input_progress;

    for  k = 1:size(joint_range_list,2)
        if config.Train_Joint_No == 1
            Theta = 0;
        else
            Theta = joint_range_list{k}{config.Theta_Joint_No};
            Theta = int32(rad2deg(Theta));
        end
        joint_range = joint_range_list{k};
        [joint_trajectory, jranges_ranges] = generate_joint_grid(joint_range);
        sample_size = size(joint_trajectory,2);
        desired_effort = zeros(7,sample_size, sample_num);
        current_position = zeros(7,sample_size,sample_num);

        %Planning the trajectory to pre-plan
        if is_collision_checking
            if (k==1 || k==size(joint_range_list,2))
                mtm_arm.move_joint(joint_trajectory(:,1));
                % mtm_arm.move_joint(joint_trajectory(:,int32((1+end)/2)));
                mtm_arm.move_joint(joint_trajectory(:,end));
            end
        end
        if is_collecting_data
            fprintf('Collecting torque data with Theta joint %d at angle %d, moving joint %d in %s direction (%5.2f%%, %s)\n',...
                config.Theta_Joint_No,...
                Theta,...
                config.Train_Joint_No,...
                dir_name,...
                current_progress,...
                datestr(datenum(0, 0, 0, 0, 0, toc), 'HH:MM:SS'));
            lastsize = 0; % to erase last printed line
            for i=1:sample_size
                mtm_arm.move_joint(joint_trajectory(:,i));
                pause(steady_time);
                for j=1:sample_num
                    pause(0.01); % pause 10ms assuming dVRK console publishes at about 100Hz so we get different samples
                    [~, ~, desired_effort(:,i,j)] = mtm_arm.get_state_joint_desired();
                    [current_position(:,i,j), ~, ~] = mtm_arm.get_state_joint_current();
                end
                fprintf(repmat('\b', 1, lastsize));
                lastsize = fprintf('Angle %d (%5.2f%%), do not touch MTM..', int32(rad2deg(joint_trajectory(config.Train_Joint_No, i))), current_progress);
                % update progress
                current_progress = current_progress + one_data_progress_increment;
            end
            fprintf(repmat('\b', 1, lastsize)); % clear last printed line
            if exist(data_save_path)~=7
                mkdir(data_save_path)
            end
            current_date_time =datestr(datetime('now'),'mmmm-dd-yyyy-HH:MM:SS');
            file_str = strcat(data_save_path,'/',sprintf('theta%d-',Theta),current_date_time,'.mat');
            save(file_str,...
                'joint_trajectory','jranges_ranges','desired_effort',...
                'current_position','Theta','current_date_time');
              output_progress = current_progress;
        end
    end
end

function [joint_trajectory,j_ranges] = generate_joint_grid(joint_range)
    %  Institute: The Chinese University of Hong Kong
    %  Author(s):  Hongbin LIN, Vincent Hui, Samuel Au
    %  Created on: 2018-10-05

    j_ranges = joint_range;
    [j7,j6,j5,j4,j3,j2,j1] = ndgrid(j_ranges{7},j_ranges{6},j_ranges{5},j_ranges{4},j_ranges{3},j_ranges{2},j_ranges{1});
    joint_trajectory = [j1(:),j2(:),j3(:),j4(:),j5(:),j6(:),j7(:)]';
end
