function [sourcemodel, nonsym_sourcemodel, recursion_depth] = intersect_sourcemodels( ...
    sourcemodel, nonsym_sourcemodel, return_recursion_depth, recursion_depth)
    % Find the intersection between the symmetrically constrained
    % sourcemodel and the one without, maintaining the symmetry constraint

    arguments
        sourcemodel
        nonsym_sourcemodel
        return_recursion_depth = false
        recursion_depth = 1
    end
    
    if recursion_depth > 2
        ME = MException('Recusion depth > 2 reach. This is not intended.');
        throw(ME)
    end

    % Stack the symmetric Nx6 .pos array to 2Nx3 like the non-symmetric
    % source model
    sourcemodel_pos_stacked = [sourcemodel.pos(:,1:3); sourcemodel.pos(:,4:6)];

    % Find the intersection of rows between the two arrays, maintaing the
    % order of the non-symmetric model's array
    [~,ia,ib] = intersect(nonsym_sourcemodel.pos, sourcemodel_pos_stacked, 'rows','stable');

    % Update the non-symmetric model .pos, .inside, and .dim. This is
    % entirely straightforward as ?x3 is the final shape
    nonsym_sourcemodel.pos = nonsym_sourcemodel.pos(ia, :);
    nonsym_sourcemodel.inside = nonsym_sourcemodel.inside(ia, :);
    nonsym_sourcemodel.dim = [numel(unique(nonsym_sourcemodel.pos(:,1))) ...
        numel(unique(nonsym_sourcemodel.pos(:,2)))...
        numel(unique(nonsym_sourcemodel.pos(:,3)))];

    % For the symmetric model, first extract the intersection
    tmp = sourcemodel_pos_stacked(ib,:);
    % Then, extract the left and right hemisphere rows individually, based
    % on the sign of y, and sort the rows to the original ordering
    lh = sortrows(tmp(tmp(:,2) > 0,:),[2,3],{'ascend' 'ascend'});
    rh = sortrows(tmp(tmp(:,2) < 0,:),[2,3],{'descend' 'ascend'});
    
    % The intersection is not necessarily symmetric, so enforce symmetry
    % We will recursively call the function to achieve symmetry
    recurse_flag = false; 
    tmp = {rh, lh};
    % The only difference between the left and right hemispheric arrays
    % should be the sign of y, so find the intersection between the
    % absolute values
    C = intersect(lh(:,2), abs(rh(:,2)));
    % Iterate over hemispheres
    for h = 1:numel(tmp)
        % Define a logical array for masking away non-symmetry
        idx_to_keep = false(height(tmp{h}), 1);
        % Compare the array y-values to each vale in the intersection
        for c = C'
            % As the intersection was between absolute values, we need to
            % reintroduce the negative sign for the right hemisphere
            c = c * (-1)^h;
            % Update mask
            idx_to_keep = bitor(...
                idx_to_keep, ...
                tmp{h}(:,2) == c ...
                );
        end
        
        % Mask away non-symmetry
        tmp{h} = tmp{h}(idx_to_keep,:);
        
        % If any rows were removed, we have altered the intersection
        % between the symmetric and non-symmetric source models, and we
        % need to find the new intersection.
        if any(idx_to_keep==0)
            recurse_flag = true;
        end
    end
    
    % Concatenate the hemispheres
    sourcemodel_pos_unstacked = [tmp{2} tmp{1}];

    % Check that nothing ouotside the masking was messed up
    [~,~,ic] = intersect(sourcemodel_pos_unstacked,sourcemodel.pos,'rows', 'stable');
    assert (all(sourcemodel.pos(ic, :) == sourcemodel_pos_unstacked,'all'));

    % Update the symmetric model .pos, .inside, and .dim.
    sourcemodel.pos = sourcemodel.pos(ic, :);
    sourcemodel.inside = sourcemodel.inside(ic, :);
    sourcemodel.dim = [numel(unique(sourcemodel.pos(:,1))) ...
        numel(unique(sourcemodel.pos(:,2)))...
        numel(unique(sourcemodel.pos(:,3)))];

    % Enforcing symmetry, we may have altered the intersection, so we call
    % the function recursively to fix this. A recursion depth =< 2 is
    % expected.
    if recurse_flag
        recursion_depth = recursion_depth + 1;
        [sourcemodel, nonsym_sourcemodel, recursion_depth] = intersect_sourcemodels( ...
            sourcemodel, nonsym_sourcemodel, return_recursion_depth, recursion_depth);
    end
end