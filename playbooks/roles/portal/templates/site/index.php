{% include 'rachel_modlist.php' %}
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
    <title>{{ portal__title }}</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    {% if use_sphider is defined and use_sphider %}
        {% include 'sphider_js.html' %}
    {% endif %}
    <style>
        {% include 'rachel.css' %}
        {% include 'portal.css' %}
    </style>
</head>


{% if use_sphider is defined and use_sphider %}
    <body onload="$('#main-search').focus();">
{% else %}
    <body>
{% endif %}
<div class="inner">
<div class="heading">
    <h1>{{ portal__title }}</h1>
    <h2>{{ portal__subtitle }}</h2>
    <div class="about">
        {{ portal__description }}
    </div>
</div>

{# 
    TODO: see if we can adapt the sphider search 
    engine the RACHEL uses.
    http://www.sphider-plus.eu/index.php?f=14#14_2
    https://github.com/needlestack/rachel-content/
#}
{% if use_sphider is defined and use_sphider %}
<div class="searchbar">
    <form action="rsphider/search.php">
      <div>
      <input id="main-search" name="query_t" value="" size="50" autocomplete="off">
      <input type="submit" value="Search local content">
      <input type="hidden" name="search" value="1">
      </div>
    </form>
</div>
{% endif %}

<div id="content">
<?php
    $mods = rachel_get_modlist();
    //print "<pre>".print_r($mods,true)."</pre>";
    if ( sizeof($mods) == 0 ) {
        print "<div class='notification'>No local content modules found</div>";   
    } else {
        foreach ( $mods as $mod) {
            print '<div class="portal subsite">';
            rachel_print_mod_fragment($mod);
            print '</div>';
        } 
    }
?>
</div>
</div>
</body>
</html>
