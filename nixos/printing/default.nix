{ config, pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  hardware.printers = {
    ensureDefaultPrinter = "NET_Office_HP-M2891fdw";
    ensurePrinters = [
      {
        name = "NET_Office_HP-M2891fdw";
        description = "HP_Color_LaserJet_Pro_MFP-M2891fdw";
        location = "Büro Network";
        deviceUri = "socket://drucker:9100";
        model = "HP/hp-color_laserjet_mfp_m278-m281-ps.ppd.gz";
        ppdOptions = {
          PageSize = "A4";

          #Doppelseitiger Druck (Bindung an der langen Seite)
          HPOption_Duplexer = "true";
          Duplex = "DuplexNoTumble";
        };
      }
      {
        name = "NET_Fritz.Box_Office_HP-M2891fdw";
        description = "HP_Color_LaserJet_Pro_MFP-M2891fdw";
        location = "Büro drucker fritz.box";
        deviceUri = "socket://NPIEA545A:9100";
        model = "HP/hp-color_laserjet_mfp_m278-m281-ps.ppd.gz";
        ppdOptions = {
          PageSize = "A4";

          #Doppelseitiger Druck (Bindung an der langen Seite)
          HPOption_Duplexer = "true";
          Duplex = "DuplexNoTumble";
        };
      }
      {
        name = "USB_Office_HP-M2891fdw";
        description = "HP_Color_LaserJet_Pro_MFP-M2891fdw";
        location = "Büro USB";
        deviceUri = "usb://HP/ColorLaserJet%20MFP%20M278-M281?serial=VNBNL1Y9WS";
        model = "HP/hp-color_laserjet_mfp_m278-m281-ps.ppd.gz";
        ppdOptions = {
          PageSize = "A4";

          #Doppelseitiger Druck (Bindung an der langen Seite)
          HPOption_Duplexer = "true";
          Duplex = "DuplexNoTumble";
        };
      }
      {
        name = "hp-officejet_pro_7740";
        description = "Knische Drucker für Traktorpulling";
        deviceUri = "hp:/usb/OfficeJet_Pro_7740_series?serial=CN98M5529H";
        model = "HP/hp-officejet_pro_7740_series.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };
  programs.system-config-printer.enable = true;
}
