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
	svgmin      = require('gulp-svgmin'),
	svg2png     = require('gulp-svg2png'),
	clean       = require('gulp-clean');


/* CSS tasks
   ========================================================== */

// clean
gulp.task('css-clean', function() {
	gulp.src(config.css.dist, {read: false})
		.pipe(clean());
});

// compile & minify
gulp.task('less', ['css-clean'], function() {
	gulp.src(config.css.src)
		.pipe(plumber())
		.pipe(sourcemaps.init())
			.pipe(less())
			.pipe(minifycss())
			.pipe(rename(config.css.id + '.css'))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(config.css.dist))
		.pipe(notify({ message: 'CSS tasks done!' }));
});


/* JS tasks
   ========================================================== */

// clean
gulp.task('js-clean', function() {
	gulp.src(config.js.dist, {read: false})
		.pipe(clean());
});

// js linter
gulp.task('js-lint', function() {
	gulp.src(config.js.src[config.js.src.length - 1])
		.pipe(plumber())
		.pipe(jshint())
		.pipe(jshint.reporter(stylish));
});

// compile & minify
gulp.task('js-scripts', ['js-lint', 'js-clean'], function() {
	gulp.src(config.js.src)
		.pipe(plumber())
		.pipe(sourcemaps.init())
			.pipe(concat(config.js.id + '.js'))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(config.js.dist))
		.pipe(notify({ message: 'JS tasks done!' }));
});


/* SVG tasks
   ========================================================== */

gulp.task('svg', function() {
	gulp.src(config.svg.src)
		.pipe(svgmin())
		.pipe(gulp.dest(config.svg.dist))
		.pipe(svg2png())
		.pipe(gulp.dest(config.svg.dist));
		.pipe(notify({ message: 'SVG tasks done!' }));
});


/* BROWSER SYNC tasks
   ========================================================== */

gulp.task('browser-sync', function() {
	browserSync({
		proxy : config.host,
		open  : false
	});
});


/* WATCH tasks
   ========================================================== */

gulp.task('watch', function() {
	gulp.watch(config.svg.src, ['svg', browserSync.reload]);
	gulp.watch(config.css.src, ['less', browserSync.reload]);
	gulp.watch(config.js.src, ['js-scripts', browserSync.reload]);
});


/* DEFAULT tasks
   ========================================================== */

gulp.task('default', ['svg', 'less', 'js-scripts', 'watch', 'browser-sync']);
