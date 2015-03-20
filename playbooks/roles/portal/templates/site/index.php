{% include 'auth.php' %}
{% include 'rachel_modlist.php' %}
<!DOCTYPE html><html lang=en>
<head>
  <meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="description" content=""><meta name="author" content="">
  <meta http-equiv="cache-control" content="no-cache">
  <link href="styles/eb66b09d.main-ltr.css" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="common.css">
  <link rel="stylesheet" type="text/css" href="style.css">
  {% include 'rachel_js.html' %}
  <title>{{ portal__title }}</title>
  <style>
  {% include 'auth_styles.css' %}
  </style>
</head>
<body id=page-top class=index>
<!-- Header -->
<header>
<div class=container>
	<div class=row>
		<div class=col-lg-12>
			<div class=intro-text>
				<span class=name>{{ portal__title }}</span> 
				<span class=skills>{{ portal__subtitle }}</span>
				<hr class=star-light>
			</div>	
		</div>
	</div>
	<div class=row>
		<div class=col-lg-8>
			<h3>About</h3>
            {{ portal__description }}
<?php
            do_auth("{{ portal__auth }}");
?>
		</div>
	</div>
</div>
</header>

<!-- Portfolio Grid Section -->
<section id=portfolio>
<div class=container>
	<div class=row>
		<div class=col-lg-12>
            <h2>Sites</h2>
            <h3>Portal powered by Project RACHEL</h3>
			<hr class=star-primary>
		</div>
	</div>
    <div class="row haut cf">
        <ul>
        <li><a href="index.php">HOME</a></li>
        <li><a href="about.html">ABOUT</a></li>
        <li><a href="local-frameset.html">LOCAL CONTENT</a></li>
        </ul>
        <form action="rsphider/search.php">
          <div>
          <input id="main-search" name="query_t" value="" size="50" autocomplete="off">
          <input type="submit" value="Search RACHEL">
          <input type="hidden" name="search" value="1">
          </div>
        </form>
    </div>
    <div class=row>
<?php
        foreach (rachel_get_modlist() as $mod) {
            print '<div class="col-sm-4 portfolio-item">';
            rachel_print_mod_fragment($mod);
            print '</div>';
        } 
?>
    </div>
</div>
</section>
<footer class=text-center>
<div class=footer-below style="display: none">
	<!-- Note: Hide it but keep it for the sake of copyrights. -->
	<div class=container><div class=row><div class=col-lg-12>
	<p style=font-size:small>
		This site was built with the <a href="http://startbootstrap.com/template-overviews/freelancer/" target=_freelancertheme>Freelancer</a> theme by <a href="http://startbootstrap.com/" target=_startbootstrap>Start Bootstrap</a>. Their work is licensed under <a href=https://github.com/IronSummitMedia/startbootstrap/blob/gh-pages/LICENSE target=_apache>Apache 2.0</a>.
	</p>
	<p style=font-size:small>
		My additions and alterations are licensed under a <a rel=license href="http://creativecommons.org/licenses/by/4.0/" target=_ccby>Creative Commons Attribution 4.0 International License</a>.
	</p>
	</div></div></div>
</div>
</footer>

<!-- Scroll to Top Button (Only visible on small and extra-small screen sizes) -->
<div class="scroll-top page-scroll visible-xs visble-sm">
	<a class="btn btn-primary" href="#page-top">
		<i class="fa fa-chevron-up"></i>
	</a>
</div>

<script language="javascript">
</script>
</body>
</html>
