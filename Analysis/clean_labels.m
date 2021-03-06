function param = clean_labels(A,mniw,param,data,left_tris)
%%% hill climb on the map sample to clean up boundary artifacts %%%

%find faces at boundaries
[conflict_faces,conflict_segs] = find_conflict(param,A);

% visualize faces at boundaries
p.t = conflict_faces';
%visualize_result(2,p,1,left_tris);


% compute current table liks
table_lik = zeros(1,param.T);
for t = 1:param.T
    table_members = param.t==t;
    table_lik(t) = compute_table_lik(mniw,data,table_members);
end



% go through the conflict faces and check if moving them improves the
% likelihood
update = 1;
lapctr = 1;
while(update)
    ind = find(conflict_faces);
    % randomly order conflict traingles.
    ind = ind(randperm(length(ind)));
    ctr = 1;
    iter_update = 0;
    
    for i = ind'
        if(ctr==100)
            fprintf('\nCleaning Labels iteration %d\n',lapctr);
        end
        ctr = ctr + 1;
        % find the likelihood of the table current face is sitting at
        curr_lik = table_lik(param.t(i));
        % potential tables to move the current face to are in conflict_segs
        potential_tabs = conflict_segs{i};
        new_lik = zeros(1,length(potential_tabs));
        for j = 1:length(potential_tabs)
            table_members = param.t==potential_tabs(j);
            table_members(i) = 1; % move the current face to table j
            new_lik(j) = 2*compute_table_lik(mniw,data,table_members);
        end
        [v,max_ind] = max(new_lik);
        % If moving the face helps assign it to the new table
        if(v>curr_lik)
            param.t(i) = potential_tabs(max_ind);
            %update stored table_likelihood
            table_lik(param.t(i)) = v;
            
            % visualize the change
           % visualize_result(3,param,1,left_tris);
            iter_update = 1;
        end
    end
    lapctr = lapctr + 1;
    % if no updates happened reset update and exit
    %param = clean_surrounded(param,A);

    %break
    if(iter_update==0)
        update = 0;
        break
    end
end
end

function param = clean_surrounded(param,A)
% return set of faces surrounded by faces from other segments

    % go through all faces
    for i = 1:param.num_data
%         nbors = A(i,:);
        curr_seg = param.t(i);
        %nbor_seg = setdiff(param.t(logical(A(i,:))),curr_seg);
        nbor_segs = param.t(logical(A(i,:)));
        
        if(isempty(intersect(nbor_segs,curr_seg)))
            param.t(i) = nbor_segs(1);
        end
        
    end
    
end

function [conflict_faces,nbors] = find_conflict(param,A)
% return set of faces that border faces from other segments
    conflict_faces = zeros(param.num_data,1);
    nbors = cell(1,param.num_data);
    % go through all faces
    for i = 1:param.num_data
%         nbors = A(i,:);
        curr_seg = param.t(i);
        %nbor_seg = setdiff(param.t(logical(A(i,:))),curr_seg);
        nbor_segs = param.t(logical(A(i,:)));
        nbor_seg = unique(nbor_segs);%nbor_segs(logical(nbor_segs - curr_seg));
        if(length(nbor_seg)>1)
            conflict_faces(i) = 1;
            nbors{i} = setdiff(nbor_seg,curr_seg);
        end
    end
    
end
