report 60141 FBM_CustOpsite_FIX
{
    Caption = 'CustOpSite';

    ProcessingOnly = true;
    Permissions = tabledata 70002 = rimd;

    dataset
    {
        dataitem(Integer; Integer)
        {

        }
    }


    trigger OnPreReport()
    var
        csite: record FBM_CustomerSite_C;
        cos: record FBM_CustOpSite;
        site: record FBM_Site;
        buf: record FBM_WSBuffer;

        customer: record Customer;
        country: record "Country/Region";
        custmast: record FBM_Customer;
        compinfo: record "Company Information";
        comp: record Company;
        comp2: record Company;
        jump: Boolean;
        window: Dialog;
    begin

        cos.DeleteAll();
        comp.FindFirst();
        window.open('#1#######/#2#######/#3#######');
        repeat

            compinfo.ChangeCompany(comp.Name);
            compinfo.get();

            if compinfo.FBM_EnSiteWS then begin

                csite.ChangeCompany(comp.name);
                csite.SetFilter("Customer No.", 'Z_*');
                csite.DeleteAll();
                csite.Reset();
                buf.setrange(WS, 'SITE');
                if buf.FindFirst() then
                    // repeat
                    //     csite.SetRange("Site Code", buf.F04);
                    //     if csite.FindFirst() then begin

                    //         case buf.F05 of
                    //             '1':
                    //                 begin

                    //                     csite.Status := csite.Status::OPERATIONAL;
                    //                 end;
                    //             '2':
                    //                 begin

                    //                     csite.Status := csite.Status::"HOLD OPERATION";
                    //                 end;
                    //             '3':
                    //                 begin

                    //                     csite.Status := csite.Status::"STOP OPERATION";
                    //                 end;
                    //             '4':
                    //                 begin

                    //                     csite.Status := csite.Status::"PRE-OPENING ";
                    //                 end;

                    //             else begin

                    //                 csite.Status := csite.Status::"DBC ADMIN";
                    //             end;
                    //         end;

                    //         csite.Modify();

                    //     end;
                    // until buf.Next() = 0;
                    csite.Reset();
                // csite.SetRange(Status, csite.Status::OPERATIONAL);
                if csite.FindFirst() then begin

                    repeat
                        jump := false;
                        if (comp.name = 'FBM Ltd') and (csite."Customer No." = 'C04790') then begin
                            csite.delete;
                            jump := true
                        end;
                        if not jump then begin

                            cos.init;
                            customer.ChangeCompany(comp.Name);
                            if csite."Customer No." <> '' then begin
                                customer.get(csite."Customer No.");
                                cos."Customer No." := customer.FBM_GrCode;
                                cos."Cust Loc Code" := customer."No.";
                                cos."Operator No." := customer.FBM_GrCode;
                                cos."Op Loc Code" := customer."No.";
                                cos."Site Loc Code" := csite."Site Code";
                                if site.get(csite.SiteGrCode) then begin
                                    if csite.SystemModifiedAt > site.SystemModifiedAt then begin
                                        cos.FBM_Sma := csite.SystemModifiedAt;
                                        cos.FBM_Sca := csite.SystemCreatedAt;
                                    end
                                    else begin
                                        cos.FBM_Sma := site.SystemModifiedAt;
                                        cos.FBM_Sca := site.SystemCreatedAt;
                                    end;
                                end
                                else begin
                                    cos.FBM_Sma := csite.SystemModifiedAt;
                                    cos.FBM_Sca := csite.SystemCreatedAt;
                                end;
                                if csite.SiteGrCode <> '' then
                                    cos."Site Code" := csite.SiteGrCode
                                else
                                    cos."Site Code" := compinfo."Custom System Indicator Text" + csite."Site Code";
                                cos.Status := csite.Status;
                                country.ChangeCompany(comp.name);
                                if country.get(customer."Country/Region Code") then
                                    cos.subsidiary := compinfo.FBM_FALessee + ' ' + country.FBM_Country3;
                                if ((customer."Country/Region Code" = 'PH') and (UpperCase(comp.Name) = 'FBM LTD')) then
                                    csite.Status := csite.Status::"STOP OPERATION";
                                csite.Modify();
                                if (csite.Status <> csite.status::OPERATIONAL) and (csite.Status <> csite.status::"HOLD OPERATION") then
                                    cos.IsActive := false else
                                    cos.IsActive := true;
                                cos."Valid From" := Today;
                                cos."Valid To" := DMY2Date(31, 12, 2999);
                                cos."Record Owner" := UserId;
                                //if cos.IsActive then
                                cos.Insert();
                            end;

                        end;
                    until csite.Next() = 0;
                end;
            end;
            buf.setrange(WS, 'FA');
        // if buf.FindFirst() then
        //     repeat
        //         fa.ChangeCompany(comp.Name);
        //         fa.setautoCalcFields(FBM_IsEGM);
        //         fa.SetRange("Serial No.", buf.F04);
        //         fa.SetRange(FBM_IsEGM, true);
        //         if fa.FindFirst() then begin
        //             case buf.F05 of
        //                 '4':
        //                     fa.FBM_Status := FA.FBM_Status::"D. Installed Op.";
        //                 '5':
        //                     FA.FBM_Status := FA.FBM_Status::"E. Installed Non-Op.";
        //                 '6':
        //                     fa.FBM_Status := fa.FBM_Status::"F. Under Maintenance";
        //                 '7':
        //                     fa.FBM_Status := fa.FBM_Status::"G. For Disposal";
        //                 '8':
        //                     fa.FBM_Status := fa.FBM_Status::"H. Scrapped";
        //                 else
        //                     fa.FBM_Status := fa.FBM_Status;



        //             end;
        //             fa.FBM_Lessee := buf.F07;
        //             comp2.FindFirst();
        //             repeat
        //                 csite.ChangeCompany(comp2.Name);
        //                 csite.setrange("Site Code", buf.F06);
        //                 if csite.FindFirst() then begin
        //                     fa.FBM_Site := csite.SiteGrCode;
        //                     csite.CalcFields("Country/Region Code_FF");
        //                     IF country.get(csite."Country/Region Code_FF") then
        //                         FA.FBM_Subsidiary := BUF.F07 + ' ' + country.FBM_Country3;
        //                     if (((csite."Country/Region Code_FF" = 'PH') or csite.IsEmpty) and (UpperCase(comp.Name) = 'FBM LTD')) then
        //                         fa.FBM_Status := fa.FBM_Status::"I. Sold";
        //                 end
        //             until comp2.next = 0;
        //             fa.Modify();
        //         end;

        //     until buf.Next() = 0;
        until comp.Next() = 0;


    end;
}