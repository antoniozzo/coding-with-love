/*******************************************************************************
1. DEPENDENCIES
*******************************************************************************/

var gulp        = require('gulp'),
	less        = require('gulp-less'),
	uglify      = require('gulp-uglify'),
	jshint      = require('gulp-jshint'),
	concat      = require('gulp-concat'),
	notify      = require('gulp-notify'),
	plumber     = require('gulp-plumber'),
	stylish     = require('jshint-stylish'),
	minifycss   = require('gulp-minify-css'),
	sourcemaps  = require('gulp-sourcemaps'),
	browserSync = require('browser-sync');


/*******************************************************************************
2. FILE DESTINATIONS
*******************************************************************************/

var config = {
	css: {
		src  : [
			'assets/src/less/main.less'
		],
		dist : 'assets/dist/css'
	},
	js: {
		src  : [
			'assets/src/js/plugins/**/*.js',
			'assets/src/js/main.js'
		],
		dist : 'assets/dist/js'
	}
};


/*******************************************************************************
3. LESS TASK
*******************************************************************************/

gulp.task('less', function() {
	gulp.src(config.css.src)
		.pipe(plumber())
		.pipe(sourcemaps.init())
			.pipe(less())
			.pipe(minifycss())
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(config.css.dist))
		.pipe(notify({ message: 'Less complete' }));
});


/*******************************************************************************
4. JS TASKS
*******************************************************************************/

// lint my custom js
gulp.task('js-lint', function() {
	gulp.src(config.js.src[config.js.src.length - 1])
		.pipe(plumber())
		.pipe(jshint())
		.pipe(jshint.reporter(stylish));
});

// concatinate custom scripts
gulp.task('js-scripts', function() {
	gulp.src(config.js.src)
		.pipe(plumber())
		.pipe(sourcemaps.init())
			.pipe(concat('scripts.js'))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(config.js.dist))
		.pipe(notify({ message: 'JS scripts complete' }));
});


/*******************************************************************************
5. WATCH TASK
*******************************************************************************/

gulp.task('watch', function() {
	gulp.watch(config.css.src, ['less', browserSync.reload]);
	gulp.watch(config.js.src, ['js-lint', 'js-scripts', browserSync.reload]);
});


/*******************************************************************************
6. BROWSER SYNC
*******************************************************************************/

gulp.task('browser-sync', function() {
	browserSync({
		proxy : config.host,
		open  : false
	});
});


/*******************************************************************************
7. GULP TASKS
*******************************************************************************/

gulp.task('default', ['less', 'js-lint', 'js-scripts', 'watch', 'browser-sync']);