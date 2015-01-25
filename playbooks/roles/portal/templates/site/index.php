{% include 'auth.php' %}
<!DOCTYPE html><html lang=en>
<head>
  <meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="description" content=""><meta name="author" content="">
  <meta http-equiv="cache-control" content="no-cache">
  <link href="styles/eb66b09d.main-ltr.css" rel="stylesheet">
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
				<span class=name>x2go</span> 
				<span class=skills>{{ portal__title }}</span>
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
			<hr class=star-primary>
		</div>
	</div>
    <div class=row>
        <!--
        <div class="col-sm-4 portfolio-item">
            <a href="/wikipedia" class=portfolio-link>
                <img src=images/logos/54e2a1b5.wikipedia.png class=img-responsive alt="">
            </a>
            <p class="intro">Wikipedia intro</p>
        </div>
        -->
        <div class="col-sm-4 portfolio-item">
            <a href="/edx" class=portfolio-link>
                <img src=images/logos/6718b4ba.openedx.png class=img-responsive alt="">
            </a>
            <p class="intro">Take courses provided by top universities and other learning institutions. You can also create your own courses with <a href="/edxcms">edX Studio</a></p>
        </div>
        <div class="col-sm-4 portfolio-item">
            <a href="/kalite" class=portfolio-link>
                <img src=images/logos/8c9907b6.kalite.png class=img-responsive alt="">
            </a>
            <p class="intro">Take courses on basic subjects provided by Khan Academy Lite</p>
        </div>
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

<script src="scripts/fd628491.script.js"></script>
</body>
</html>
