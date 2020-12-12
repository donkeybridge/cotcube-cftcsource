# frozen_string_literal: true

module Cotcube
  module CftcSource

    CFTC_LINKS = {
      disagg: {
        fut: {
          current: 'https://www.cftc.gov/dea/newcot/f_disagg.txt',
          hist: 'https://www.cftc.gov/files/dea/history/fut_disagg_txt_'
        },
        com: {
          current: 'https://www.cftc.gov/dea/newcot/c_disagg.txt',
          hist: 'https://www.cftc.gov/files/dea/history/com_disagg_txt_'
        }
      },
      legacy: {
        fut: {
          current: 'https://www.cftc.gov/dea/newcot/deafut.txt',
          hist: 'https://www.cftc.gov/files/dea/history/deacot'
        },
        com: {
          current: 'https://www.cftc.gov/dea/newcot/deacom.txt',
          hist: 'https://www.cftc.gov/files/dea/history/deahistfo'
        }
      },
      financial: {
        fut: {
          current: 'https://www.cftc.gov/dea/newcot/FinFutWk.txt',
          hist: 'https://www.cftc.gov/files/dea/history/fut_fin_txt_'
        },
        com: {
          current: 'https://www.cftc.gov/dea/newcot/FinComWk.txt',
          hist: 'https://www.cftc.gov/files/dea/history/com_fin_txt_'
        }
      },
      cit: {
        com: {
          current: 'https://www.cftc.gov/dea/newcot/deacit.txt',
          hist: 'https://www.cftc.gov/files/dea/history/dea_cit_txt_'
        }
      }
    }.freeze

    CFTC_HEADERS = { 
      legacy: %i[ name date date2 cftcid cftcid2 cftcid3 cftcid3] +
      %i[ std_count_oi_all std_count_ncom_long std_count_ncom_short std_count_ncom_spread std_count_com_long std_count_com_short] + 
      %i[ std_count_rept_long std_count_rept_short std_count_nrept_long std_count_nrept_short] +
      %i[ old_count_oi_all old_count_ncom_long old_count_ncom_short old_count_ncom_spread old_count_com_long old_count_com_short] +
      %i[ old_count_rept_long old_count_rept_short old_count_nrept_long old_count_nrept_short] +
      %i[ other_count_oi_all other_count_ncom_long other_count_ncom_short other_count_ncom_spread other_count_com_long other_count_com_short] +
      %i[ other_count_rept_long other_count_rept_short other_count_nrept_long other_count_nrept_short] +
      %i[ std_change_oi_all std_change_ncom_long std_change_ncom_short std_change_ncom_spread std_change_com_long std_change_com_short] +
      %i[ std_change_rept_long std_change_rept_short std_change_nrept_long std_change_nrept_short] +
      %i[ std_pct_oi_all std_pct_ncom_long std_pct_ncom_short std_pct_ncom_spread std_pct_com_long std_pct_com_short] +
      %i[ std_pct_rept_long std_pct_rept_short std_pct_nrept_long std_pct_nrept_short] +
      %i[ old_pct_oi_all old_pct_ncom_long old_pct_ncom_short old_pct_ncom_spread old_pct_com_long old_pct_com_short] +
      %i[ old_pct_rept_long old_pct_rept_short old_pct_nrept_long old_pct_nrept_short] +
      %i[ other_pct_oi_all other_pct_ncom_long other_pct_ncom_short other_pct_ncom_spread other_pct_com_long other_pct_com_short] +
      %i[ other_pct_rept_long other_pct_rept_short other_pct_nrept_long other_pct_nrept_short] +
      %i[ std_traders_oi_all std_traders_ncom_long std_traders_ncom_short std_traders_ncom_spread std_traders_com_long std_traders_com_short] +
      %i[ std_traders_rept_long std_traders_rept_short] + 
      %i[ old_traders_oi_all old_traders_ncom_long old_traders_ncom_short old_traders_ncom_spread old_traders_com_long old_traders_com_short] +
      %i[ old_traders_rept_long old_traders_rept_short] +
      %i[ other_traders_oi_all other_traders_ncom_long other_traders_ncom_short other_traders_ncom_spread other_traders_com_long] +
      %i[ other_traders_com_short other_traders_rept_long other_traders_rept_short] +
      %i[ std_conc_gross4_long std_conc_gross4_short std_conc_gross8_long std_conc_gross8_short std_conc_net4_long std_conc_net4_short] +
      %i[ std_conc_net8_long std_conc_net8_short old_conc_gross4_long old_conc_gross4_short old_conc_gross8_long old_conc_gross8_short] +
      %i[ old_conc_net4_long old_conc_net4_short old_conc_net8_long old_conc_net8_short other_conc_gross4_long other_conc_gross4_short] +
      %i[ other_conc_gross8_long other_conc_gross8_short other_conc_net4_long other_conc_net4_short other_conc_net8_long other_conc_net8_short] +
      %i[ units CFTCContractMarketCode(Quotes) CFTCMarketCodeinInitials(Quotes) CFTCCommodityCode(Quotes) supplement],

      disagg: %i[name date date2 cftcid cftcid2 cftcid3 cftcid3] +
      %i[ std_count_oi_all std_count_prod_long std_count_prod_short std_count_swap_long std_count_swap_short std_count_swap_spread] + 
      %i[ std_count_money_long std_count_money_short std_count_money_spread std_count_other_long std_count_other_short std_count_other_spread] + 
      %i[ std_count_rept_long std_count_rept_short std_count_nrept_long std_count_nrept_short] +
      %i[ old_count_oi_all old_count_prod_long old_count_prod_short old_count_swap_long old_count_swap_short old_count_swap_spread] +
      %i[ old_count_money_long old_count_money_short old_count_money_spread old_count_other_long old_count_other_short old_count_other_spread] +
      %i[ old_count_rept_long old_count_rept_short old_count_nrept_long old_count_nrept_short] +
      %i[ other_count_oi_all other_count_prod_long other_count_prod_short other_count_swap_long other_count_swap_short other_count_swap_spread] +
      %i[ other_count_money_long other_count_money_short other_count_money_spread other_count_other_long other_count_other_short other_count_other_spread] +
      %i[ other_count_rept_long other_count_rept_short other_count_nrept_long other_count_nrept_short] +
      %i[ std_change_oi_all std_change_prod_long std_change_prod_short std_change_swap_long std_change_swap_short std_change_swap_spread] +
      %i[ std_change_money_long std_change_money_short std_change_money_spread std_change_other_long std_change_other_short std_change_other_spread] +
      %i[ std_change_rept_long std_change_rept_short std_change_nrept_long std_change_nrept_short] +
      %i[ std_pct_oi_all std_pct_prod_long std_pct_prod_short std_pct_swap_long std_pct_swap_short std_pct_swap_spread] +
      %i[ std_pct_money_long std_pct_money_short std_pct_money_spread std_pct_other_long std_pct_other_short std_pct_other_spread] +
      %i[ std_pct_rept_long std_pct_rept_short std_pct_nrept_long std_pct_nrept_short] +
      %i[ old_pct_oi_all old_pct_prod_long old_pct_prod_short old_pct_swap_long old_pct_swap_short old_pct_swap_spread old_pct_money_long] +
      %i[ old_pct_money_short old_pct_money_spread old_pct_other_long old_pct_other_short old_pct_other_spread] +
      %i[ old_pct_rept_long old_pct_rept_short old_pct_nrept_long old_pct_nrept_short] + 
      %i[ other_pct_oi_all other_pct_prod_long other_pct_prod_short other_pct_swap_long other_pct_swap_short other_pct_swap_spread] +
      %i[ other_pct_money_long other_pct_money_short other_pct_money_spread other_pct_other_long other_pct_other_short other_pct_other_spread] +
      %i[ other_pct_rept_long other_pct_rept_short other_pct_nrept_long other_pct_nrept_short] + 
      %i[ std_traders_oi_all std_traders_prod_long std_traders_prod_short std_traders_swap_long std_traders_swap_short std_traders_swap_spread] +
      %i[ std_traders_money_long std_traders_money_short std_traders_money_spread std_traders_other_long std_traders_other_short std_traders_other_spread] +
      %i[ std_traders_rept_long std_traders_rept_short] +
      %i[ old_traders_oi_all old_traders_prod_long old_traders_prod_short old_traders_swap_long old_traders_swap_short old_traders_swap_spread] +
      %i[ old_traders_money_long old_traders_money_short old_traders_money_spread old_traders_other_long old_traders_other_short old_traders_other_spread] +
      %i[ old_traders_rept_long old_traders_rept_short] +
      %i[ other_traders_oi_all other_traders_prod_long other_traders_prod_short other_traders_swap_long other_traders_swap_short] +
      %i[ other_traders_swap_spread other_traders_money_long other_traders_money_short other_traders_money_spread other_traders_other_long] +
      %i[ other_traders_other_short other_traders_other_spread other_traders_rept_long other_traders_rept_short] + 
      %i[ std_conc_gross4_long std_conc_gross4_short std_conc_gross8_long std_conc_gross8_short std_conc_net4_long std_conc_net4_short std_conc_net8_long] +
      %i[ std_conc_net8_short old_conc_gross4_long old_conc_gross4_short old_conc_gross8_long old_conc_gross8_short old_conc_net4_long old_conc_net4_short] +
      %i[ old_conc_net8_long old_conc_net8_short other_conc_gross4_long other_conc_gross4_short other_conc_gross8_long other_conc_gross8_short] +
      %i[ other_conc_net4_long other_conc_net4_short other_conc_net8_long other_conc_net8_short] + 
      %i[ units CFTC_Contract_Market_Code_Quotes CFTC_Market_Code_Quotes CFTC_Commodity_Code_Quotes CFTC_SubGroup_Code Fut_Combined supplement],

      financial: %i[ name date date2 cftcid cftcid2 cftcid3 cftcid3] +
      %i[ std_count_oi_all std_count_dealers_long std_count_dealers_short std_count_dealers_spread std_count_asset_long std_count_asset_short] +
      %i[ std_count_asset_spread std_count_lev_long std_count_lev_short std_count_lev_spread std_count_other_long std_count_other_short] + 
      %i[ std_count_other_spread std_count_rept_long std_count_rept_short std_count_nrept_long std_count_nrept_short] +
      %i[ std_change_oi_all std_change_dealers_long std_change_dealers_short std_change_dealers_spread std_change_asset_long std_change_asset_short] +
      %i[ std_change_asset_spread std_change_lev_long std_change_lev_short std_change_lev_spread std_change_other_long std_change_other_short] +
      %i[ std_change_other_spread std_change_rept_long std_change_rept_short std_change_nrept_long std_change_nrept_short] +
      %i[ std_pct_oi_all std_pct_dealers_long std_pct_dealers_short std_pct_dealers_spread std_pct_asset_long std_pct_asset_short] +
      %i[ std_pct_asset_spread std_pct_lev_long std_pct_lev_short std_pct_lev_spread std_pct_other_long std_pct_other_short] +
      %i[ std_pct_other_spread std_pct_rept_long std_pct_rept_short std_pct_nrept_long std_pct_nrept_short] +
      %i[ std_traders_oi_all std_traders_dealers_long std_traders_dealers_short std_traders_dealers_spread std_traders_asset_long std_traders_asset_short] +
      %i[ std_traders_asset_spread std_traders_lev_long std_traders_lev_short std_traders_lev_spread std_traders_other_long std_traders_other_short std] +
      %i[_traders_other_spread std_traders_rept_long std_traders_rept_short] +
      %i[ std_conc_gross4_long std_conc_gross4_short std_conc_gross8_long std_conc_gross8_short std_conc_net4_long std_conc_net4_short] +
      %i[ std_conc_net8_long std_conc_net8_short] +
      %i[ units CFTC_Contract_Market_Code_Quotes CFTC_Market_Code_Quotes CFTC_Commodity_Code_Quotes CFTC_SubGroup_Code type supplement],


      cit: %i[name date date2 cftcid cftcid2 cftcid3 cftcid3] + 
      %i[std_count_oi_all std_count_ncom_long std_count_ncom_short std_count_ncom_spread std_count_com_long std_count_com_short] + 
      %i[std_count_rept_long std_count_rept_short std_count_nrept_long std_count_nrept_short std_count_cit_long std_count_cit_short] + 
      %i[std_change_oi_all std_change_ncom_long std_change_ncom_short std_change_ncom_spread std_change_com_long std_change_com_short] +
      %i[std_change_rept_long std_change_rept_short std_change_nrept_long std_change_nrept_short std_change_cit_long std_change_cit_short] +
      %i[std_pct_oi_all std_pct_ncom_long std_pct_ncom_short std_pct_ncom_spread std_pct_com_long std_pct_com_short] +
      %i[std_pct_rept_long std_pct_rept_short std_pct_nrept_long std_pct_nrept_short std_pct_cit_long std_pct_cit_short] +
      %i[std_traders_oi_all std_traders_ncom_long std_traders_ncom_short std_traders_ncom_spread std_traders_com_long std_traders_com_short] +
      %i[std_traders_rept_long std_traders_rept_short std_traders_cit_long std_traders_cit_short] +
      %i[units supplement]
    }.freeze

    CFTC_SYMBOL_EXAMPLES = [
      { id: "13874U", symbol: "ET", ticksize: 0.25, power: 1.25, months: "HMUZ", bcf: 1.0, reports: "LF", name: "S&P 500 MICRO" },
      { id: "209747", symbol: "NM", ticksize: 0.25, power: 0.5,  monhts: "HMUZ", bcf: 1.0, reports: "LF", name: "NASDAQ 100 MICRO" }
    ].freeze


  end
end
