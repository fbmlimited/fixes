codeunit 61501 FBM_Fixes
{
    Permissions = tabledata "Purch. Inv. Line" = rimd, tabledata "G/L Entry" = rimd, tabledata "Sales Invoice Header" = rimd, tabledata "Purch. Cr. Memo Hdr." = RIMD, tabledata "Purch. Inv. Header" = RIMD;
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
    begin
        comp.FindFirst();
        repeat
            cle.ChangeCompany(comp.Name);
            sinv.ChangeCompany(comp.Name);
            if cle.FindFirst() then
                repeat
                    if sinv.get(cle."Document No.") then
                        if sinv.FBM_Site <> '' then begin
                            cle.FBM_Site := sinv.FBM_Site;
                            cle.Modify();
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
        glentry.SetRange("Document No.", 'PPI105549');
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
        exchrate.ChangeCompany('NTT Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(01, 08, 2023), DMY2Date(31, 08, 2023));
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
    begin
        cexch.SetRange("Starting Date", DMY2Date(21, 07, 2023));
        cexch2.SetRange("Starting Date", DMY2Date(22, 07, 2023), DMY2Date(24, 07, 2023));
        cexch2.DeleteAll();
        cexch2.Reset();
        if cexch.FindFirst() then
            repeat
                cexch2.init;
                cexch2."Starting Date" := DMY2Date(22, 07, 2023);
                cexch2."Currency Code" := cexch."Currency Code";
                cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                cexch2.Insert();
                cexch2.init;
                cexch2."Starting Date" := DMY2Date(23, 07, 2023);
                cexch2."Currency Code" := cexch."Currency Code";
                cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                cexch2.Insert();
                cexch2.init;
                cexch2."Starting Date" := DMY2Date(24, 07, 2023);
                cexch2."Currency Code" := cexch."Currency Code";
                cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                cexch2.Insert();
            until cexch.Next() = 0;
        message('Done');
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



}