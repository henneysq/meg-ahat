function data_details_cfg = get_data_details()
    data_details_cfg = [];
    
    all_subs = 1:30;
    
    data_details_cfg.old_trigger_subs = [1:7 10 12 14:17 19:20];
    data_details_cfg.new_trigger_subs = setdiff(all_subs, data_details_cfg.old_trigger_subs);
    assert(length(data_details_cfg.new_trigger_subs) == length(data_details_cfg.old_trigger_subs))
    
    generic_strct = [];
    generic_strct.run1 = [];
    generic_strct.run2 = [];
    
    for sub = all_subs
        data_details_cfg.(sprintf('sub%03d', sub)) = [];
        data_details_cfg.(sprintf('sub%03d', sub)).run1 = [];
        data_details_cfg.(sprintf('sub%03d', sub)).run2 = [];
    end
    
    data_details_cfg.sub001.run1.suffix = 'a042d115'; % commit ID
    data_details_cfg.sub001.run2.suffix = 'a042d115';
    
    data_details_cfg.sub002.run1.suffix = 'a042d115';
    data_details_cfg.sub002.run2.suffix = 'a042d115';
    
    data_details_cfg.sub003.run1.suffix = 'a042d115';
    data_details_cfg.sub003.run2.suffix = 'a042d115';
    
    data_details_cfg.sub004.run1.suffix = 'a042d115';
    data_details_cfg.sub004.run2.suffix = 'a042d115';
    
    data_details_cfg.sub005.run1.suffix = 'a042d115';
    data_details_cfg.sub005.run2.suffix = 'a042d115';
    
    data_details_cfg.sub006.run1.suffix = 'b995195c';
    data_details_cfg.sub006.run2.suffix = 'b995195c';
    
    data_details_cfg.sub007.run1.suffix = '234e5f40';
    data_details_cfg.sub007.run2.suffix = 'b2aef43d';
    
    data_details_cfg.sub008.run1.suffix = '00e480a9';
    data_details_cfg.sub008.run2.suffix = '00e480a9';
    
    data_details_cfg.sub009.run1.suffix = 'af7905d8';
    data_details_cfg.sub009.run2.suffix = 'af7905d8';
    
    data_details_cfg.sub010.run1.suffix = 'cc66c65b';
    data_details_cfg.sub010.run2.suffix = 'cc66c65b';
    
    data_details_cfg.sub011.run1.suffix = '00e480a9';
    data_details_cfg.sub011.run2.suffix = '00e480a9';
    
    data_details_cfg.sub012.run1.suffix = 'd70eacfb';
    data_details_cfg.sub012.run2.suffix = 'd70eacfb';
    
    data_details_cfg.sub013.run1.suffix = '00e480a9';
    data_details_cfg.sub013.run2.suffix = '00e480a9';
    
    data_details_cfg.sub014.eyetrack_missing = true;
    data_details_cfg.sub014.run1.suffix = 'cc66c65b';
    data_details_cfg.sub014.run2.suffix = 'cc66c65b';
    
    data_details_cfg.sub015.run1.suffix = 'fbd05d5a';
    data_details_cfg.sub015.run2.suffix = 'fbd05d5a';
    
    data_details_cfg.sub016.run1.suffix = 'cc66c65b';
    data_details_cfg.sub016.run2.suffix = 'cc66c65b';
    
    data_details_cfg.sub017.run1.suffix = 'fbd05d5a';
    data_details_cfg.sub017.run2.suffix = 'fbd05d5a';
    
    data_details_cfg.sub018.run1.suffix = '00e480a9';
    data_details_cfg.sub018.run2.suffix = '00e480a9';
    
    data_details_cfg.sub019.run1.suffix = 'cc66c65b_00'; % commit ID + overwrite protection index
    data_details_cfg.sub019.run2.suffix = 'cc66c65b';
    
    data_details_cfg.sub020.run1.suffix = 'cc66c65b';
    data_details_cfg.sub020.run2.suffix = 'cc66c65b';
    
    data_details_cfg.sub021.run1.suffix = '00e480a9';
    data_details_cfg.sub021.run2.suffix = '00e480a9';
    
    data_details_cfg.sub022.run1.suffix = '00e480a9';
    data_details_cfg.sub022.run2.suffix = '00e480a9';
    
    data_details_cfg.sub023.run1.suffix = '00e480a9';
    data_details_cfg.sub023.run2.suffix = '00e480a9';
    
    data_details_cfg.sub024.run1.suffix = '7e9fd61a';
    data_details_cfg.sub024.run2.suffix = '7e9fd61a';
    
    data_details_cfg.sub025.run1.suffix = '00e480a9';
    data_details_cfg.sub025.run2.suffix = '00e480a9';
    
    data_details_cfg.sub026.run1.suffix = '7e9fd61a';
    data_details_cfg.sub026.run2.suffix = '7e9fd61a';
    
    data_details_cfg.sub027.run1.suffix = '00e480a9';
    data_details_cfg.sub027.run2.suffix = '00e480a9';
    
    data_details_cfg.sub028.run1.suffix = '87a85519';
    data_details_cfg.sub028.run2.suffix = '87a85519';
    
    data_details_cfg.sub029.run1.suffix = '00e480a9';
    data_details_cfg.sub029.run2.suffix = '00e480a9';
    
    data_details_cfg.sub030.run1.suffix = 'af7905d8';
    data_details_cfg.sub030.run2.suffix = 'af7905d8';
end