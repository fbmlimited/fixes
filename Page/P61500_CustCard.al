page 61500 CustCard
{
    Caption = 'Cust Card temp';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Customer;
    ShowFilter = true;


    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                // FIELD(FBM_GrCode; Rec.FBM_GrCode)
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(fixcutsopsite)
            {
                ApplicationArea = All;

                trigger OnAction()
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
                                nrec := csite.Count;
                                repeat
                                    jump := false;
                                    if (comp.name = 'FBM Ltd') and (csite."Customer No." = 'C04790') then begin
                                        csite.delete;
                                        jump := true
                                    end;
                                    if not jump then begin
                                        crec += 1;
                                        winupdate(nrec, crec, comp.Name, '');
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

                    message('done');
                end;
            }
            action(importsite)
            {
                ApplicationArea = All;
                trigger
                OnAction()
                begin
                    Xmlport.run(60101, true, true);
                end;
            }
            action(fixvat)
            {
                ApplicationArea = All;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixvat();
                end;
            }
            action(importFA)
            {
                ApplicationArea = All;
                trigger
                OnAction()
                begin
                    Xmlport.run(60102, true, true);
                end;
            }
            action(fixexchrate)
            {
                ApplicationArea = All;


                trigger OnAction()
                var
                    exchrate: record "Currency Exchange Rate";
                    exchrate2: record "Currency Exchange Rate";
                begin
                    exchrate.SetRange("Starting Date", DMY2Date(12, 07, 2023));
                    exchrate.DeleteAll();
                    exchrate.SetRange("Starting Date", DMY2Date(10, 07, 2023));
                    if exchrate.FindFirst() then
                        repeat
                            exchrate2.Init();
                            exchrate2."Starting Date" := DMY2Date(12, 07, 2023);
                            exchrate2."Currency Code" := exchrate."Currency Code";
                            exchrate2."Exchange Rate Amount" := exchrate."Exchange Rate Amount";
                            exchrate2."Adjustment Exch. Rate Amount" := exchrate."Adjustment Exch. Rate Amount";
                            exchrate2."Relational Exch. Rate Amount" := exchrate."Relational Exch. Rate Amount";
                            exchrate2."Fix Exchange Rate Amount" := exchrate."Fix Exchange Rate Amount";
                            exchrate2."Relational Adjmt Exch Rate Amt" := exchrate."Relational Adjmt Exch Rate Amt";
                            exchrate2.Insert();
                        until exchrate.Next() = 0;
                    message('done');
                end;
            }
            action(mergegroup)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    groupN: record FBM_CustGroup;
                    groupD: record FBM_CustGroup;
                    custn: record Customer;
                    custd: record Customer;
                    custm: record FBM_Customer;

                begin
                    groupN.ChangeCompany('NTT Ltd Branch');
                    groupD.ChangeCompany('D2R Ltd Branch');
                    GROUPN.RESET;
                    GROUPD.Reset();
                    groupN.FindFirst();
                    repeat
                        groupd.SetRange(Group, groupn.Group);
                        groupd.Setrange(SubGroup, groupN.SubGroup);
                        iF NOT GROUPD.FindFirst() then begin
                            groupD.Init();
                            groupD.Group := groupN.Group;
                            groupD."Group Name" := groupN."Group Name";
                            groupD.SubGroup := groupN.SubGroup;
                            groupD."SubGroup Name" := groupN."SubGroup Name";
                            GROUPD.IsGroup := groupN.IsGroup;
                            groupD.Insert();
                        end;

                    until groupn.Next() = 0;
                    GROUPN.RESET;
                    GROUPD.Reset();
                    groupd.FindFirst();
                    repeat
                        groupn.SetRange(Group, groupd.Group);
                        groupn.Setrange(SubGroup, groupd.SubGroup);
                        if NOT groupN.FindFirst() then begin
                            groupn.Init();
                            groupn.Group := groupd.Group;
                            groupn."Group Name" := groupd."Group Name";
                            groupn.SubGroup := groupd.SubGroup;
                            groupn."SubGroup Name" := groupd."SubGroup Name";
                            GROUPN.IsGroup := GROUPD.IsGroup;
                            groupn.Insert();
                        end;

                    until groupd.Next() = 0;
                    custn.ChangeCompany('NTT Ltd Branch');
                    custd.ChangeCompany('D2R Ltd Branch');

                    custd.FindFirst();
                    repeat
                        custm.Reset();
                        custn.SetRange(FBM_GrCode, custd.FBM_GrCode);
                        if custn.FindFirst() then
                            custm.SetRange("No.", custN.FBM_GrCode);
                        if custm.FindFirst() then BEGIN
                            if custn.FBM_Group <> '' then
                                custm.FBM_Group := custn.FBM_Group;
                            if CUSTN.FBM_SubGroup <> '' then
                                CUSTM.FBM_SubGroup := CUSTN.FBM_SubGroup;

                            if (custd.FBM_Group <> custn.FBM_Group) AND (CUSTN.FBM_Group <> '') AND (CUSTD.FBM_Group <> '') then
                                custm.FBM_Group := 'COLLISION';
                            IF (CUSTD.FBM_SubGroup <> CUSTN.FBM_SubGroup) AND (CUSTN.FBM_SubGroup <> '') AND (CUSTD.FBM_SubGroup <> '') then
                                CUSTM.FBM_SubGroup := 'COLLISION';
                            custm.Modify();
                        END;
                    UNTIL CUSTD.Next() = 0;
                    CUSTN.Reset();
                    CUSTD.Reset();
                    custN.FindFirst();
                    repeat
                        custm.Reset();
                        custD.SetRange(FBM_GrCode, custN.FBM_GrCode);
                        if custd.FindFirst() then
                            custm.SetRange("No.", custD.FBM_GrCode);
                        if custm.FindFirst() then BEGIN
                            if custn.FBM_Group <> '' then
                                custm.FBM_Group := custD.FBM_Group;
                            if custn.FBM_SubGroup <> '' then
                                CUSTM.FBM_SubGroup := CUSTD.FBM_SubGroup;

                            if (custN.FBM_Group <> custD.FBM_Group) AND (CUSTN.FBM_Group <> '') AND (CUSTD.FBM_Group <> '') then
                                custm.FBM_Group := 'COLLISION';
                            IF (CUSTD.FBM_SubGroup <> CUSTN.FBM_SubGroup) AND (CUSTN.FBM_SubGroup <> '') AND (CUSTD.FBM_SubGroup <> '') then
                                CUSTM.FBM_SubGroup := 'COLLISION';
                            custm.Modify();
                        END;
                    UNTIL CUSTN.Next() = 0;

                    message('Done');
                end;
            }
        }
    }
    trigger
    OnOpenPage()
    begin
        REC.SETFILTER("No.", '%1', 'FBMTEST*');
    end;

    var
        window: Dialog;
        crec: Integer;
        nrec: Integer;
        FA: RECORD "Fixed Asset";

    local procedure winupdate(NoOfRecs: integer;
CurrRec: integer;
ntable: text[100];
compname: text[100])
    begin
        window.Update(1, compname);
        window.Update(2, ntable);
        if NoOfRecs > 0 then
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(3, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(3, (CurrRec / NoOfRecs * 10000) DIV 1);

    end;
}