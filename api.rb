module Elvuel
  module OpenTaobao
    module API
      @@api_list = [
        { :name => "taobao.taobaoke.listurl.get", :name_dynamic => "TaobaokeListurlGet", :params => %w(q* nick* outer_code), :session_key_require => false, :add_methods => "" },
        {
          :name => "taobao.taobaoke.items.get", :name_dynamic => "TaobaokeItemsGet", :params => %w(fields* nick keyword cid start_price end_price auto_send area start_credit end_credit sort guarantee start_commissionRate end_commissionRate start_commissionNum end_commissionNum start_totalnum end_totalnum cash_coupon vip_card overseas_item sevendays_return real_describe onemonth_repair cash_ondelivery mall_item page_no page_size outer_code), :session_key_require => false, :add_methods => ""
        },
        {
          :name => "taobao.user.get", :name_dynamic => "TaobaoUserGet", :params => %w(fields* nick*), :session_key_require => false, :add_methods => ""
        },
        {
          :name => "taobao.users.get", :name_dynamic => "TaobaoUsersGet", :params => %w(fields* nicks*), :session_key_require => false, :add_methods => ""
        },
        {
          :name => "taobao.traderates.get", :name_dynamic => "TaobaoTraderatesGet", :params => %w(fields* rate_type* role* result page_no page_size), :session_key_require => true, :add_methods => ""
        },
        {
          :name => "taobao.trades.bought.get", :name_dynamic => "TaobaoTradesBoughtGet", :params => %w(fields* start_created end_created status seller_nick type page_no page_size rate_status), :session_key_require => true, :add_methods => ""
        },
        {
          :name => "taobao.product.get", :name_dynamic => "TaobaoProductGet", :params => %w(fields* product_id cid props), :session_key_require => false, :add_methods => ""
        },
        {
          :name => "taobao.product.add", :name_dynamic => "TaobaoProductAdd", :params => %w(cid* outer_id props binds sale_props customer_props price* image*! name* desc major native_unkeyprops), :session_key_require => true, :add_methods => "" 
        }
      ]
      
      class << self
        def list
          @@api_list
        end
        
        def list=(apis)
          @@api_list = apis
        end
      end
      
    end
  end
end