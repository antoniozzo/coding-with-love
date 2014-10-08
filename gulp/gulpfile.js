/* Imports
   ================================================ */

var config      = require('./gulpconfig.json'),
	gulp        = require('gulp'),
	less        = require('gulp-less'),
	uglify      = require('gulp-uglify'),
	jshint      = require('gulp-jshint'),
	concat      = require('gulp-concat'),
	notify      = require('gulp-notify'),
	plumber     = require('gulp-plumber'),
	rename      = require('gulp-rename'),
	stylish     = require('jshint-stylish'),
	minifycss   = require('gulp-minify-css'),
	sourcemaps  = require('gulp-sourcemaps'),
	browserSync = require('browser-sync'),
	handlebars  = require('gulp-ember-handlebars'),
	svgmin      = require('gulp-svgmin'),
	svg2png     = require('gulp-svg2png'),
	clean       = require('gulp-clean'),
	rev         = require('gulp-rev'),
	seq         = require('gulp-run-sequence'),
	revO        = require('gulp-rev-outdated');


/* CSS tasks
   ========================================================== */

// clean
gulp.task('css-clean', function() {
	return gulp.src(config.css.dist, {read: false})
		.pipe(clean());
});

// compile & minify
gulp.task('less', function() {
	return gulp.src(config.css.src)
		.pipe(plumber())
		.pipe(sourcemaps.init())
			.pipe(less())
			.pipe(minifycss())
			.pipe(rename(config.css.id + '.css'))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(config.css.dist))
		.pipe(notify({
			title    : 'CSS',
			subtitle : 'success',
			message  : "Created file: <%= file.relative %>!"
		}));
});


/* JS tasks
   ========================================================== */

// clean
gulp.task('js-clean', function() {
	return gulp.src(config.js.dist, {read: false})
		.pipe(clean());
});

// templates
gulp.task('templates', function() {
	return gulp.src([config.templates.src])
		.pipe(plumber())
		.pipe(handlebars({outputType: 'browser'}))
		.pipe(concat(config.templates.id + '.js'))
		.pipe(gulp.dest(config.templates.dist))
		.pipe(notify({
			title    : 'Handlebars',
			subtitle : 'success',
			message  : "Created file: <%= file.relative %>!"
		}));
});

// js linter
gulp.task('js-lint', function() {
	return gulp.src(config.js.src)
		.pipe(plumber())
		.pipe(jshint())
		.pipe(jshint.reporter(stylish));
});

// compile & minify
gulp.task('js-scripts', ['js-lint'], function() {
	return gulp.src(config.js.vendor.concat(config.js.src))
		.pipe(plumber())
		.pipe(sourcemaps.init())
			.pipe(concat(config.js.id + '.js'))
			.pipe(uglify())
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(config.js.dist))
		.pipe(notify({
			title    : 'JS',
			subtitle : 'success',
			message  : "Created file: <%= file.relative %>!"
		}));
});


/* SVG tasks
   ========================================================== */

gulp.task('svg', function() {
	return gulp.src(config.svg.src)
		.pipe(svgmin())
		.pipe(gulp.dest(config.svg.dist))
		.pipe(svg2png())
		.pipe(gulp.dest(config.svg.dist))
		.pipe(notify({
			title    : 'SVG',
			subtitle : 'success',
			message  : "Created file: <%= file.relative %>!"
		}));
});


/* REVISION tasks
   ========================================================== */

gulp.task('rev-clean', function() {
	return gulp.src([
			config.css.dist + '/*.css',
			config.js.dist + '/*.js'
		], {read: false})
        .pipe(revO(1))
        .pipe(clean());
});

gulp.task('rev', function() {
	return gulp.src([
			config.css.dist + '/' + config.css.id + '.css',
			config.js.dist + '/' + config.js.id + '.js',
		], {base: config.rev.dist})
		.pipe(gulp.dest(config.rev.dist))
		.pipe(rev())
		.pipe(gulp.dest(config.rev.dist))
		.pipe(rev.manifest())
		.pipe(gulp.dest(config.rev.dist))
		.pipe(notify({
			title    : 'REV',
			subtitle : 'success',
			message  : "Created file: <%= file.relative %>!"
		}));
});


/* BROWSER SYNC tasks
   ========================================================== */

gulp.task('browser-sync', function() {
	browserSync({
		proxy : config.browser.host,
		open  : false
	});
});


/* WATCH tasks
   ========================================================== */

gulp.task('watch', function() {
	gulp.watch(config.svg.src, ['svg'/*, browserSync.reload*/]);

	gulp.watch(config.css.src, function() {
		seq('less', 'rev-clean', 'rev'/*, browserSync.reload*/);
	});

	gulp.watch(config.js.src, function() {
		seq('js-scripts', 'rev-clean', 'rev'/*, browserSync.reload*/);
	});

	gulp.watch(config.templates.src, function() {
		seq('templates', 'js-scripts', 'rev-clean', 'rev'/*, browserSync.reload*/);
	});
});


/* DEFAULT tasks
   ========================================================== */

gulp.task('default', ['watch', 'browser-sync']);

