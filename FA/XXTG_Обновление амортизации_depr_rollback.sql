declare
l_asset_hdr_rec fa_api_types.asset_hdr_rec_type;
l_return_status VARCHAR2(1);
l_mesg_count number;
l_mesg varchar2(4000);

begin
        dbms_output.enable(1000000);
        FA_SRVR_MSG.Init_Server_Message;

        for dst_data in (select asset_id from FA_ADDITIONS)
        loop
                l_asset_hdr_rec.asset_id := dst_data.asset_id;
                l_asset_hdr_rec.book_type_code := 'BEST_FA_LOCAL';

                FA_DEPRN_ROLLBACK_PUB.do_rollback
                    (p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                    p_calling_fn => null,
                    x_return_status => l_return_status,
                    x_msg_count => l_mesg_count,
                    x_msg_data => l_mesg,
                    px_asset_hdr_rec => l_asset_hdr_rec
                    );

                l_mesg_count := fnd_msg_pub.count_msg;
                
                if l_mesg_count > 0 
                then
                    l_mesg := chr(10) || substr(fnd_msg_pub.get (fnd_msg_pub.G_FIRST,fnd_api.G_FALSE), 1, 250);
                    dbms_output.put_line(l_mesg);
                    
                    for i in 1..(l_mesg_count - 1)
                    loop
                        l_mesg := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT,fnd_api.G_FALSE), 1, 250);
                        dbms_output.put_line(l_mesg);
                    end loop;
                    
                    fnd_msg_pub.delete_msg();
                end if;
                
                if (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                then
                    dbms_output.put_line('FAILURE=' || dst_data.asset_id);
                else
                    dbms_output.put_line('SUCCESS=' || dst_data.asset_id);
                end if;
                
        end loop;
        commit;
end;
