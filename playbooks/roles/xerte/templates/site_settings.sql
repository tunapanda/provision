# {{ansible_managed}}

USE {{xerte__db_name}};

DELETE FROM {{xerte__db_prefix}}sitedetails; 
INSERT INTO {{xerte__db_prefix}}sitedetails(site_id) VALUES(1) ; 

{% for field in [
	{'name':'site_url','value':xerte__site_url},
    {'name':'apache','value':xerte__apache},
    {'name':'mimetypes','value':xerte__mimetypes},
    {'name':'LDAP_preference','value':xerte__LDAP_preference},
    {'name':'LDAP_filter','value':xerte__LDAP_filter},
    {'name':'integration_config_path','value':xerte__integration_config_path},
    {'name':'admin_username','value':xerte__admin_username},
    {'name':'admin_password','value':xerte__admin_password},
    {'name':'site_session_name','value':xerte__site_session_name},
    {'name':'site_title','value':xerte__site_title},
    {'name':'site_name','value':xerte__site_name},
    {'name':'site_logo','value':xerte__site_logo},
    {'name':'organisational_logo','value':xerte__organisational_logo},{'name':'welcome_message','value':xerte__welcome_message},
    {'name':'site_text','value':xerte__site_text},
    {'name':'news_text','value':xerte__news_text},
    {'name':'pod_one','value':xerte__pod_one},
    {'name':'pod_two','value':xerte__pod_two},
    {'name':'copyright','value':xerte__copyright},
    {'name':'rss_title','value':xerte__rss_title},
    {'name':'synd_publisher','value':xerte__synd_publisher},
    {'name':'synd_rights','value':xerte__synd_rights},
    {'name':'synd_license','value':xerte__synd_license},
    {'name':'demonstration_page','value':xerte__demonstration_page},
    {'name':'form_string','value':xerte__form_string},
    {'name':'peer_form_string','value':xerte__peer_form_string},
    {'name':'module_path','value':xerte__module_path},
    {'name':'website_code_path','value':xerte__website_code_path},
    {'name':'users_file_area_short','value':xerte__users_file_area_short},
    {'name':'php_library_path','value':xerte__php_library_path},
    {'name':'error_log_path','value':xerte__error_log_path},
    {'name':'email_error_list','value':xerte__email_error_list},
    {'name':'error_log_message','value':xerte__error_log_message},
    {'name':'max_error_size','value':xerte__max_error_size},
    {'name':'error_email_message','value':xerte__error_email_message},
    {'name':'max_error_size','value':xerte__max_error_size},
    {'name':'error_email_message','value':xerte__error_email_message},
    {'name':'ldap_host','value':xerte__ldap_host},
    {'name':'ldap_port','value':xerte__ldap_port},
    {'name':'bind_pwd','value':xerte__bind_pwd},
    {'name':'basedn','value':xerte__basedn},
    {'name':'bind_dn','value':xerte__bind_dn},
    {'name':'flash_save_path','value':xerte__flash_save_path},
    {'name':'flash_upload_path','value':xerte__flash_upload_path},
    {'name':'flash_preview_check_path','value':xerte__flash_preview_check_path},
    {'name':'flash_flv_skin','value':xerte__flash_flv_skin},
    {'name':'site_email_account','value':xerte__site_email_account},
    {'name':'headers','value':xerte__headers},
    {'name':'email_to_add_to_username','value':xerte__email_to_add_to_username},
    {'name':'proxy1','value':xerte__proxy1},
    {'name':'port1','value':xerte__port1},
    {'name':'feedback_list','value':xerte__feedback_list},
    {'name':'play_edit_preview_query','value':xerte__play_edit_preview_query},
    {'name':'import_path','value':xerte__import_path},
    {'name':'root_file_path','value':xerte__root_file_path},
]%}
UPDATE {{xerte__db_prefix}}sitedetails SET {{field.name}} = "{{field.value}}" WHERE site_id = 1; 
{% endfor %}

## TODO: LDAP


