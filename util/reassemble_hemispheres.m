function reassembled_pos = reassemble_hemispheres(sources_left_h, sources_right_h, reference, parameter)

    if not(all(sources_right_h.dim == sources_left_h.dim))
        ME = MException('Dimensions of left and right hemispheres must be identical');
        throw(ME)
    end
    dim = sources_left_h.dim;
    if not(all(dim.*[1 2 1] == reference.dim))
        ME = MException('Dimensions of individual hemispheres must TODO');
        throw(ME)
    end

    try
        ids = [];
        idrd = [];
        idld = [];

        stride = dim(1)*dim(3);
        consec = dim(1);
        for z = 1:dim(3)
            for y = 1:dim(2)
                ids = [ids (1:consec)+(y-1)*stride+(z-1)*consec];
                idrd = [idrd (1:consec)+(y-1)*consec+(z-1)*stride];
                idld = [idld (1:consec)+(y-1)*consec+(z-.5)*stride];
            end
        end

        for d = 1:3
            reassembled_pos = zeros(prod(dim)*2,1);
            if d == 2
                flipped_right = flip(sources_right_h.pos);
                reassembled_pos(idrd) = flipped_right(ids,d+3);
            else
                reassembled_pos(idrd) = sources_right_h.pos(ids,d+3);
            end
            reassembled_pos(idld) = sources_left_h.pos(ids,d);
            assert (all(reassembled_pos == reference.pos(:,d)))
        end
        

    catch % the above assertion - could be more specific
        ids = [];
        idrd = [];
        idld = [];

        stride = dim(1)*dim(2);
        consec = stride;
        for z = 1:dim(3)
                ids = [ids (1:consec)+(z-1)*stride];
                idrd = [idrd (1:consec)+(z-1)*stride*2];
                idld = [idld (1:consec)+((z-1)+.5)*stride*2];
        end


        for d = 1:3
            reassembled_pos = zeros(prod(dim)*2,1);
            if d == 2
                flipped_right = flip(sources_right_h.pos);
                reassembled_pos(idrd) = flipped_right(ids,d+3);
            else
                reassembled_pos(idrd) = sources_right_h.pos(ids,d+3);
            end
            reassembled_pos(idld) = sources_left_h.pos(ids,d);
            assert (all(reassembled_pos == reference.pos(:,d)))
        end
    end

    % figure;plot(reassembled_pos,'LineWidth',2);hold on; plot(ref_vals,'r--','LineWidth',2)

    par_fields = strsplit(parameter, '.');
    for n = 1:numel(par_fields)
        par_field = par_fields{n};
        sources_left_h = sources_left_h.(par_field);
        sources_right_h = sources_right_h.(par_field);

    end

    par_vals_right_flipped = flip(sources_right_h);
    reassembled_pos = zeros(prod(dim)*2,1);
    reassembled_pos(idrd) = par_vals_right_flipped(ids);
    reassembled_pos(idld) = sources_left_h(ids);
end