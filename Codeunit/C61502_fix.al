codeunit 61501 FBM_Fixes
{
    Permissions = tabledata "Value Entry" = rimd, tabledata "VAT Entry" = rimd, tabledata "Detailed Cust. Ledg. Entry" = rimd, tabledata "Bank Account Ledger Entry" = rimd, tabledata "Purch. Inv. Line" = rimd, tabledata "G/L Entry" = rimd, tabledata "Sales Invoice Header" = rimd, tabledata "Purch. Cr. Memo Hdr." = RIMD, tabledata "Purch. Inv. Header" = RIMD, tabledata "G/L Account" = rimd, tabledata "Vendor Ledger Entry" = rimd;



    procedure fixqty()

    var
        pinvline: record "Purch. Inv. Line";
    begin
        pinvline.SetRange("Document No.", 'P-APV003105');
        pinvline.SetRange("Line No.", 610000);
        if pinvline.FindFirst() then begin
            pinvline.Validate(Quantity, 1);
            pinvline.Modify();
        end;


    end;

    procedure dimonoff(seton: Boolean)
    var
        defdim: record "Default Dimension";
        comp: record Company;
    begin
        comp.FindFirst();
        repeat
            defdim.ChangeCompany(comp.Name);
            defdim.SetRange("Table ID", 15);

            if defdim.FindFirst() then
                repeat

                    if defdim."Value Posting" = defdim."Value Posting"::"Code Mandatory" then begin
                        defdim.FBM_Marked := true;
                        defdim.Modify();
                    end;
                    if seton then begin
                        if defdim.FBM_Marked then
                            defdim."Value Posting" := defdim."Value Posting"::"Code Mandatory";

                    end
                    else
                        if defdim.FBM_Marked then
                            defdim."Value Posting" := defdim."Value Posting"::" ";
                    defdim.Modify()
                until defdim.Next() = 0;
        until comp.Next() = 0;

    end;

    procedure setsite()
    var
        sinv: record "Sales Invoice Header";
        cle: record "Cust. Ledger Entry";
        comp: record Company;
        scrm: record "Sales Cr.Memo Header";
        glsetup: record "General Ledger Setup";
        dimhall: integer;
    begin


        comp.FindFirst();
        repeat
            cle.ChangeCompany(comp.Name);
            sinv.ChangeCompany(comp.Name);
            scrm.ChangeCompany(comp.Name);
            glsetup.ChangeCompany(comp.Name);
            glsetup.get;
            dimhall := 0;
            if glsetup."Shortcut Dimension 3 Code" = 'HALL' then dimhall := 3;
            if glsetup."Shortcut Dimension 4 Code" = 'HALL' then dimhall := 4;
            if glsetup."Shortcut Dimension 5 Code" = 'HALL' then dimhall := 5;
            if glsetup."Shortcut Dimension 6 Code" = 'HALL' then dimhall := 6;
            if glsetup."Shortcut Dimension 7 Code" = 'HALL' then dimhall := 7;
            if glsetup."Shortcut Dimension 8 Code" = 'HALL' then dimhall := 8;
            if comp.Name = 'NTT Ltd Branch' then begin // 4 SPECIFIC CASES, HARDCODED
                cle.SetRange("Document No.", 'CR2023/22284');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH03AS03-0008';
                        cle.Modify();
                    until cle.Next() = 0;

                cle.SetRange("Document No.", 'CR2023/22803');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH0TYG02-0001';
                        cle.Modify();
                    until cle.Next() = 0;
                cle.SetRange("Document No.", 'CR2024/25190');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH0PTG01-0002';
                        cle.Modify();
                    until cle.Next() = 0;
                cle.SetRange("Document No.", 'CR2024/25553');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH0ECP03-0010';
                        cle.Modify();
                    until cle.Next() = 0;
                cle.Reset();
            end;
            if cle.FindFirst() then
                repeat
                    if sinv.get(cle."Document No.") then begin //INVOICE
                        if (sinv.FBM_Site <> '') and (cle.FBM_Site = '') then begin

                            cle.FBM_Site := sinv.FBM_Site;
                            cle.Modify();
                        end;
                    end
                    else

                        if scrm.get(cle."Document No.") then begin // CREDIT MEMO
                            if (scrm.FBM_Site <> '') and (cle.FBM_Site = '') then begin

                                cle.FBM_Site := scrm.FBM_Site;
                                cle.Modify();
                            end;
                        end
                        ELSE begin
                            if cle."Source Code" = 'CASHRECJNL' THEN BEGIN// reading the sit from HALL dimension
                                case dimhall of
                                    3:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 3 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 3 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 3 Code";
                                        END;
                                    4:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 4 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 4 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 4 Code";
                                        END;
                                    5:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 5 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 5 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 5 Code";
                                        END;
                                    6:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 6 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 6 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 6 Code";
                                        END;
                                    7:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 7 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 7 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 7 Code";
                                        END;
                                    8:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 8 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 8 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 8 Code";
                                        END
                                end;
                                cle.Modify();
                            END;
                        end;
                until cle.Next() = 0;

        until comp.Next() = 0;
        message('done');
    end;

    procedure setnames()
    var
        customer: record Customer;
        custle: record "Cust. Ledger Entry";
        vendor: record Vendor;
        vendle: record "Vendor Ledger Entry";
        comp: record Company;
    begin
        comp.FindFirst();
        repeat
            customer.ChangeCompany(comp.Name);
            custle.ChangeCompany(comp.Name);
            vendor.ChangeCompany(comp.Name);
            vendle.ChangeCompany(comp.Name);
            if custle.FindFirst() then
                repeat
                    if customer.get(custle."Customer No.") then
                        if custle."Customer Name" = '' then begin
                            custle."Customer Name" := customer.Name;
                            custle.Modify();
                        end;
                until custle.Next() = 0;
            if vendle.FindFirst() then
                repeat
                    if vendor.get(vendle."Vendor No.") then
                        if vendle."Vendor Name" = '' then begin
                            vendle."Vendor Name" := vendor.Name;
                            vendle.Modify();
                        end;
                until vendle.Next() = 0;

        until comp.Next() = 0;
        message('done');
    end;

    procedure delgle()
    var
        glentry: record "G/L Entry";
    begin
        glentry.SetRange("Entry No.", 463078);
        glentry.DeleteAll();
        message('Done');
    end;


    procedure fixpo()
    var
        pline: record "Purchase Line";
    begin
        pline.SetRange("Document Type", pline."Document Type"::Order);
        pline.SetRange("Document No.", '005148');
        pline.SetRange("Line No.", 10000);
        if pline.FindFirst() then begin
            pline."Prepayment Amount" := 0;
            pline."Prepmt. Amt. Incl. VAT" := 0;
            pline."Prepmt. Amount Inv. Incl. VAT" := 859485.86;
            pline."Prepmt. Line Amount" := 859485.87;
            pline."Prepmt. VAT Base Amt." := 0;
            pline."Prepmt. Amt. Inv." := 859485.86;
            pline.Modify();
        end;

    end;


    procedure delbankerr()
    var
        bankle: record "Bank Account Ledger Entry";
    begin
        bankle.setrange("Bank Account No.", 'ERROR');
        BANKLE.ModifyAll("Bank Account No.", 'PETTY CASH EUR - DRA');
    end;


    procedure fixvat()
    var
        csite: record FBM_CustomerSite_C;
        comp: record Company;
        site: Record FBM_Site;
    begin
        comp.FindFirst();
        repeat
            csite.ChangeCompany(comp.name);
            if csite.FindFirst() then
                repeat
                    site.Reset();
                    site.SetRange("Site Code", csite.SiteGrCode);
                    if site.FindFirst() then
                        if csite."Vat Number" = '' then begin
                            csite."Vat Number" := site."Vat Number";
                            csite.Modify();
                        end;
                until csite.next = 0;
        until comp.next = 0;
        message('done');

    end;


    procedure fixacy()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('FBM Ltd');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(19, 04, 2023), DMY2Date(20, 04, 2023));
        if glentry.FindFirst() then
            repeat
                if glentry."Additional-Currency Amount" = glentry.Amount then begin
                    if abs(glentry.Amount) > 1 then begin
                        crec += 1;
                        exchrate.get('PHP', glentry."Posting Date");
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Exchange Rate Amount");
                        glentry.Modify();
                    end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixacy2()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('D2R Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(20, 12, 2023), DMY2Date(31, 12, 2023));
        if glentry.FindFirst() then
            repeat
                if (glentry."Additional-Currency Amount" = glentry.Amount) or (glentry."Additional-Currency Amount" = 0) then begin
                    if abs(glentry.Amount) > 1 then begin
                        crec += 1;
                        if exchrate.get('USD', glentry."Posting Date") then
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                        else begin
                            exchrate.get('USD', calcdate('-1D', glentry."Posting Date"));
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                        end;
                        glentry.Modify();
                    end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixacy3()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('NTT Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(01, 08, 2023), DMY2Date(31, 08, 2023));
        if glentry.FindFirst() then
            repeat
                if ((glentry."Additional-Currency Amount" < 0) and (glentry.Amount > 0)) or ((glentry."Additional-Currency Amount" > 0) and (glentry.Amount < 0)) then begin
                    //if abs(glentry.Amount) > 1 then begin
                    crec += 1;

                    glentry.validate("Additional-Currency Amount", -glentry."Additional-Currency Amount");

                    glentry.Modify();
                    // end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixdimfmq()
    var
        glentry: record "G/L Entry";
        glentry2: record "G/L Entry";
        dimmgt: Codeunit DimensionManagement;
        dse: record "Dimension Set Entry" temporary;
        nsi: Integer;
    begin
        glentry.Setfilter("Dimension Set ID", '%1|%2', 1838, 57);

        if glentry.FindFirst() then
            repeat



                dse.init();
                if glentry."Global Dimension 1 Code" <> '' then begin
                    dse."Dimension Set ID" := -1;
                    dse.validate("Dimension Code", 'BUDGET_ACCOUNT');
                    dse.validate("Dimension Value Code", glentry."Global Dimension 1 Code");
                    dse.Insert(true);
                end;


                if glentry."Global Dimension 2 Code" <> '' then begin
                    dse."Dimension Set ID" := -1;
                    dse.validate("Dimension Code", 'BUDGET_GROUP');
                    dse.validate("Dimension Value Code", glentry."Global Dimension 2 Code");
                    dse.Insert(true);
                end;


                glentry.CalcFields("Shortcut Dimension 3 Code");
                if glentry."Shortcut Dimension 3 Code" <> '' then begin
                    dse."Dimension Set ID" := -1;
                    dse.validate("Dimension Code", 'CENTRO CUSTO');

                    dse.validate("Dimension Value Code", glentry."Shortcut Dimension 3 Code");
                    dse.Insert(true);
                end;


                nsi := dimmgt.GetDimensionSetID(dse);
                if nsi <> 0 then begin
                    glentry2.get(glentry."Entry No.");
                    glentry2.validate("Dimension Set ID", nsi);
                    glentry2.Modify();
                end;
                dse.DeleteAll();
            until glentry.Next() = 0;
    end;

    procedure fixcurr()
    var
        sinv: record "Sales Invoice Header";
        cexch: record "Currency Exchange Rate";
    begin
        sinv.SetRange("Currency Code", 'PHP');
        if sinv.FindFirst() then
            repeat
                sinv.FBM_Currency2 := 'USD';
                cexch.get('PHP', sinv."Posting Date");
                sinv.CalcFields(Amount);
                sinv.FBM_LocalCurrAmt := sinv.Amount / sinv."Currency Factor";
                sinv.Modify();
            until sinv.Next() = 0;
        message('done');
    end;

    procedure fixexch()
    var
        cexch: record "Currency Exchange Rate";
        cexch2: record "Currency Exchange Rate";
        comp: record Company;
        cinfo: record "company Information";
    begin
        comp.findfirst;
        repeat
            cinfo.changecompany(comp.name);
            cinfo.get();
            cexch.changecompany(comp.name);
            cexch2.changecompany(comp.name);
            cexch.SetRange("Starting Date", DMY2Date(15, 03, 2024));
            cexch2.SetRange("Starting Date", DMY2Date(16, 03, 2024));

            if cexch.FindFirst() then
                repeat
                    cexch2.SetRange("Currency Code", cexch."Currency Code");
                    if not cexch2.FindFirst() then begin
                        cexch2.init;
                        cexch2."Starting Date" := DMY2Date(16, 03, 2024);
                        cexch2."Currency Code" := cexch."Currency Code";
                        cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                        cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                        cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                        cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                        cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                        cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                        cexch2.Insert();
                    end;

                until cexch.Next() = 0;
            message('Done 16/3');
            cexch.Reset();
            cexch2.Reset();
            cexch.SetRange("Starting Date", DMY2Date(15, 03, 2024));
            cexch2.SetRange("Starting Date", DMY2Date(17, 03, 2024));

            if cexch.FindFirst() then
                repeat
                    cexch2.SetRange("Currency Code", cexch."Currency Code");
                    if not cexch2.FindFirst() then begin
                        cexch2.init;
                        cexch2."Starting Date" := DMY2Date(17, 03, 2024);
                        cexch2."Currency Code" := cexch."Currency Code";
                        cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                        cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                        cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                        cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                        cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                        cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                        cexch2.Insert();
                    end;

                until cexch.Next() = 0;
            // message('Done 9/3');
            // cexch.Reset();
            // cexch2.Reset();
            // cexch.SetRange("Starting Date", DMY2Date(07, 03, 2024));
            // cexch2.SetRange("Starting Date", DMY2Date(10, 03, 2024));

            // if cexch.FindFirst() then
            //     repeat
            //         cexch2.SetRange("Currency Code", cexch."Currency Code");
            //         if not cexch2.FindFirst() then begin
            //             cexch2.init;
            //             cexch2."Starting Date" := DMY2Date(10, 03, 2024);
            //             cexch2."Currency Code" := cexch."Currency Code";
            //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
            //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
            //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
            //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
            //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
            //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
            //             cexch2.Insert();
            //         end;


            //     until cexch.Next() = 0;
            message('Done ' + cinfo."Custom System Indicator Text")
        until comp.next = 0;

        // cexch.Reset();
        // cexch2.Reset();
        // cexch.SetRange("Starting Date", DMY2Date(05, 03, 2024));
        // cexch2.SetRange("Starting Date", DMY2Date(07, 03, 2024));
        // if cexch.FindFirst() then
        //     repeat
        //         cexch2.SetRange("Currency Code", cexch."Currency Code");
        //         if not cexch2.FindFirst() then begin
        //             cexch2.init;
        //             cexch2."Starting Date" := DMY2Date(07, 03, 2024);
        //             cexch2."Currency Code" := cexch."Currency Code";
        //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
        //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
        //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
        //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
        //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
        //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
        //             cexch2.Insert();
        //         end;

        //     until cexch.Next() = 0;


        // message('Done');
    end;

    procedure fixcurrpurch()
    var
        purchinv: record "Purch. Inv. Header";
        purccrm: record "Purch. Cr. Memo Hdr.";
        purchhead: record "Purchase Header";
        vendor: record Vendor;
        stori: Enum "Purchase Document Status";
    begin
        purchinv.SetRange("Currency Code", 'EUR');
        if purchinv.FindFirst() then
            repeat
                purchinv."Currency Code" := '';
                purchinv.Modify()
            UNTIL PURCHINV.Next() = 0;
        purccrm.SetRange("Currency Code", 'EUR');
        if purccrm.FindFirst() then
            repeat
                purccrm."Currency Code" := '';
                purccrm.Modify()
            UNTIL purccrm.Next() = 0;
        purchhead.SetRange("Currency Code", 'EUR');
        if purchhead.FindFirst() then
            repeat
                stori := purchhead.Status;
                if purchhead.status <> purchhead.Status::Open then
                    purchhead.Status := purchhead.Status::Open;
                purchhead."Currency Code" := '';
                purchhead.Status := stori;
                purchhead.Modify()
            UNTIL purchhead.Next() = 0;
        vendor.SetRange("Currency Code", 'EUR');
        if vendor.FindFirst() then
            repeat
                vendor.Validate("Currency Code", '');
                vendor.Modify()
            UNTIL vendor.Next() = 0;
        MESSAGE('DONE');


    end;

    procedure checkacy()
    var
        glentry: record "G/L Entry";
    begin
        glentry.setrange("Posting Date", DMY2Date(1, 8, 2023), DMY2Date(30, 09, 2023));
        if glentry.FindFirst() then
            repeat
                if glentry."Additional-Currency Amount" <> 0 then
                    if ((glentry.Amount / glentry."Additional-Currency Amount") < 52) or ((glentry.Amount / glentry."Additional-Currency Amount") > 58) then
                        glentry.Mark(true);
            until glentry.Next() = 0;
        glentry.MarkedOnly(true);
        page.RunModal(20, glentry);

    end;

    procedure fixacystrange()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        pdate: date;
    begin
        glentry.setrange("Posting Date", DMY2Date(1, 8, 2023), DMY2Date(30, 09, 2023));
        if glentry.FindFirst() then
            repeat
                pdate := glentry."Posting Date";
                if (((glentry."Additional-Currency Amount" <> 0) and (glentry.Amount = 0))) or
                (((glentry."Additional-Currency Amount" < 0) and (glentry.Amount > 0)) or ((glentry."Additional-Currency Amount" > 0) and (glentry.Amount < 0))) then begin
                    if exchrate.get('USD', glentry."Posting Date") then
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                    else begin
                        while not
                       exchrate.get('USD', pdate) do begin
                            pdate := calcdate('-1D', pdate)
                        end;
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount");
                    end;
                    glentry.Modify();
                end;
                pdate := glentry."Posting Date";
                if (glentry."Additional-Currency Amount" <> 0) then
                    if (round(glentry.amount / glentry."Additional-Currency Amount", 0.01) = 0.00) or
                                    ((glentry."Additional-Currency Amount" <> 0) and ((((glentry.Amount / glentry."Additional-Currency Amount") < 52) or ((glentry.Amount / glentry."Additional-Currency Amount") > 58)))) then begin

                        if exchrate.get('USD', glentry."Posting Date") then
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                        else begin
                            while not
                           exchrate.get('USD', pdate) do begin
                                pdate := calcdate('-1D', pdate)
                            end;
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount");
                        end;
                        glentry.Modify();
                    end;
            until glentry.Next() = 0;


    end;

    procedure fixcrm()
    var
        ph: record "Purchase Header";
    begin
        ph.SetRange("Document Type", ph."Document Type"::Order);
        ph.SetRange("No.", 'INTL-NTT2022-0115');
        if ph.FindFirst() then begin
            ph."Prepmt. Cr. Memo No." := '';
            ph.Modify();
            message('Done');

        end;

    end;


    procedure fixic()
    var
        paric: record "IC Partner";
    begin
        paric.SetRange(code, 'IC0012');
        IF PARIC.FindFirst() THEN BEGIN
            PARIC."Vendor No." := 'VIC112';
            paric.Modify();
        END;
    end;


    procedure fixitem()
    var
        item: record item;
    begin
        if item.get('598522') then begin
            item."Unit Cost" := 960;
            item.Modify()
        end;
    end;

    procedure deletelog()
    var
        changelog: record "Change Log Entry";
    begin
        changelog.DeleteAll();
        message('Done');
    end;

    procedure setpermset(permset: code[20]; action: Integer)
    var
        acccont: record "Access Control";
        user: record user;
    begin
        user.SetRange(State, user.state::Enabled);
        if user.FindFirst() then
            repeat
                acccont.SetRange("User Name", user."User Name");
                acccont.SetRange("Role ID", permset);
                if action = 0 then begin
                    if acccont.FindFirst() then
                        acccont.Delete();

                end
                else
                    if acccont.IsEmpty then begin
                        acccont.Init();
                        acccont.validate("User Security ID", user."User Security ID");
                        acccont.validate("Role ID", permset);
                        acccont.Validate(Scope, acccont.Scope::System);
                        acccont.Insert(true);
                    end;

            until user.next = 0;
        message('Done');
    end;

    procedure propgroup()
    var
        cust: record customer;
        fbmcust: record FBM_Customer;
        comp: record Company;
    begin
        comp.FindFirst();
        repeat
            cust.ChangeCompany(comp.Name);
            if cust.FindFirst() then
                repeat
                    fbmcust.setrange("No.", cust.FBM_GrCode);
                    if fbmcust.FindFirst() then begin
                        fbmcust.FBM_Group := cust.FBM_Group;
                        fbmcust.FBM_SubGroup := cust.FBM_SubGroup;
                        fbmcust.Modify();
                    end;
                until cust.next = 0;
        until comp.next = 0;

    end;

    procedure fixeurvendor()
    var
        vle: record "Vendor Ledger Entry";
        vendor: record Vendor;
        PI: record "Purchase Header";
        exchrate: record "Currency Exchange Rate";
        CF: Decimal;
    begin
        IF VLE.FindFirst() then
            repeat
                if vle."Currency Code" = 'EUR' then BEGIN
                    exchrate.SetRange("Starting Date", vle."Posting Date");
                    exchrate.SetRange("Currency Code", 'EUR');
                    IF exchrate.FindFirst() THEN
                        cf := exchrate."Exchange Rate Amount"
                    else
                        while cf = 0 do begin
                            exchrate.SetRange("Starting Date", calcdate('-1D', vle."Posting Date"));
                            exchrate.SetRange("Currency Code", 'EUR');
                            cf := exchrate."Exchange Rate Amount"
                        end;

                    vle."Original Currency Factor" := cf;
                    VLE."Adjusted Currency Factor" := cf;
                    VLE.Modify();
                END;
            Until vle.next = 0;
        message('vle');
        if vendor.FindFirst() then
            repeat
                if vendor."Currency Code" = '' then begin
                    vendor."Currency Code" := 'EUR';
                    VENDOR.Modify();
                end;
            UNTIL vendor.NEXT = 0;
        message('vendor');
        if pi.FindFirst() then
            repeat
                if pi."Currency Code" = '' then begin
                    pi."Currency Code" := 'EUR';
                    pi.Modify();

                end;
            until pi.Next() = 0;
        message('Done');

    end;

    procedure fixdatesdaymonth()
    var
        glentry: record "G/L Entry";
        oldday: integer;
        oldmonth: integer;
        newday: Integer;
        newmonth: Integer;
        vtime1: time;
        vtime2: time;
    begin
        evaluate(vtime1, '09:28:00');
        evaluate(vtime2, '11:18:01');
        glentry.SetRange(SystemCreatedAt, system.CreateDateTime(DMY2Date(5, 12, 2023), vtime1), system.CreateDateTime(DMY2Date(12, 12, 2023), vtime2));
        glentry.SetRange("Source Code", 'CASHRECJNL');
        glentry.Findfirst();
        repeat
            oldday := Date2DMY(glentry."Posting Date", 1);
            oldmonth := Date2DMY(glentry."Posting Date", 2);
            newday := oldmonth;
            newmonth := oldday;
            glentry.Validate("Posting Date", DMY2Date(newday, newmonth, 2023));
            glentry.modify;
        until glentry.next = 0;

    end;

    procedure fixentries()
    var
        exchrate: record "Currency Exchange Rate";
        custle: record "Cust. Ledger Entry";
        detcustle: record "Detailed Cust. Ledg. Entry";
        bankle: record "Bank Account Ledger Entry";
        gle: record "G/L Entry";
        cc: Integer;
        VATE: RECORD "VAT Entry";
        value: record "Value Entry";
    begin
        custle.SetRange("Posting Date", DMY2Date(12, 03, 2024));
        custle.SetRange("Currency Code", 'USD');
        if custle.FindFirst() then
            repeat
                CUSTLE.CalcFields("Amount (LCY)", Amount);
                if custle.Amount <> custle."Amount (LCY)" then begin
                    cc += 1;
                    custle.VALIDATE("Sales (LCY)", custle.Amount);
                    custle.Modify();
                    gle.SetRange("Document No.", custle."Document No.");
                    if gle.FindFirst() then
                        repeat
                            gle.Validate(Amount, gle.amount / 55.889);
                            exchrate.get('EUR', gle."Posting Date");
                            gle.validate("Additional-Currency Amount", gle.Amount * exchrate."Exchange Rate Amount");
                            gle.Modify();
                        until gle.Next() = 0;
                    VATE.SetRange("Document No.", custle."Document No.");
                    if VATE.FindFirst() then
                        repeat
                            VATE.Validate(BASE, VATE.BASE / 55.889);
                            VATE.Modify();
                        until VATE.Next() = 0;
                    value.SetRange("Document No.", custle."Document No.");
                    if value.FindFirst() then
                        repeat
                            value.Validate("Sales Amount (Actual)", value."Sales Amount (Actual)" / 55.889);
                            value.Modify();
                        until value.Next() = 0;
                end;
            until custle.Next() = 0;
        Message(format(cc));
        cc := 0;
        detcustle.SetRange("Posting Date", DMY2Date(12, 03, 2024));
        detcustle.SetRange("Currency Code", 'USD');
        if detcustle.FindFirst() then
            repeat

                if detcustle.Amount <> detcustle."Amount (LCY)" then begin
                    cc += 1;
                    detcustle.VALIDATE("Amount (LCY)", detcustle.Amount);
                    detcustle.Modify();
                end;
            until detcustle.Next() = 0;
        Message(format(cc));
        cc := 0;
        bankle.SetRange("Posting Date", DMY2Date(11, 03, 2024));
        bankle.SetRange("Currency Code", 'USD');
        if bankle.FindFirst() then
            repeat

                if bankle.Amount <> bankle."Amount (LCY)" then begin
                    cc += 1;
                    bankle.validate("Amount (LCY)", bankle.Amount);


                    bankle.Modify();
                end;
            until bankle.Next() = 0;
        Message(format(cc));
    end;

    procedure fixentries2()
    var

        cc: Integer;
        bankle: record "Bank Account Ledger Entry";
        gle: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
    begin
        cc := 0;
        bankle.SetRange("Posting Date", DMY2Date(11, 03, 2024));
        bankle.SetRange("Currency Code", 'USD');
        if bankle.FindFirst() then
            repeat

                if bankle.Amount <> bankle."Amount (LCY)" then begin
                    cc += 1;
                    bankle.validate("Amount (LCY)", bankle.Amount);
                    gle.SetRange("Document No.", bankle."Document No.");
                    gle.SetRange("Posting Date", DMY2Date(11, 03, 2024));
                    if gle.FindFirst() then
                        repeat
                            gle.validate(Amount, gle.Amount / 55.889);
                            exchrate.get('EUR', gle."Posting Date");
                            gle.validate("Additional-Currency Amount", gle.Amount * exchrate."Exchange Rate Amount");
                            gle.Modify();
                        until gle.Next() = 0;


                    bankle.Modify();
                end;
            until bankle.Next() = 0;
        Message(format(cc));
    end;

    procedure fixactive()
    var
        cos: record FBM_CustOpSite;
        csite: Record FBM_CustomerSite_C;
        comp: record Company;
        cinfo: record "Company Information";
        subs: text[20];
        country: record "Country/Region";

    begin
        comp.FindFirst();
        repeat
            cinfo.ChangeCompany(comp.Name);
            cinfo.get();
            country.ChangeCompany(comp.Name);
            if cinfo.FBM_EnSiteWS then begin
                csite.ChangeCompany(comp.Name);
                csite.FindFirst();
                repeat

                    cos.Reset();
                    subs := '';
                    csite.CalcFields("Country/Region Code_FF");
                    if country.get(csite."Country/Region Code_FF") then
                        subs := cinfo."Custom System Indicator Text" + ' ' + country.FBM_Country3;
                    cos.SetRange(Subsidiary, subs);
                    cos.SetRange("Site Loc Code", csite."Site Code");

                    if cos.FindFirst() then begin
                        case csite.Status of
                            csite.Status::"DBC ADMIN", csite.status::"HOLD OPERATION", csite.Status::OPERATIONAL:
                                cos.IsActive := true;
                            csite.Status::"PRE-OPENING ", csite.status::"STOP OPERATION":
                                cos.IsActive := false;
                        end;
                        cos.Modify();

                    end;
                until csite.Next() = 0;
            end;

        until comp.Next() = 0;
        cos.Reset();
        cos.setfilter("Site Loc Code", '%1|%2|%3', 'SITE1222', 'SITE1223', 'SITE1224');
        COS.DeleteAll();
        message('done');

    end;
}