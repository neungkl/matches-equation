var gulp = require('gulp');
var coffee = require('gulp-coffee');
var coffeelint = require('gulp-coffeelint');
var header = require('gulp-header');
var sass = require('gulp-sass');
var uglify = require('gulp-uglify');
var minifyCss = require('gulp-minify-css');
var jade = require('gulp-jade');
var browserSync = require('browser-sync').create();

var isMin = false;

var creditText = [
  '/* Develope by : Kosate Limpongsa',
  ' * https://github.com/kosate/matchesequation',
  ' */'
].join('\n') + "\n";


gulp.task('js',function() {
  var tmp =
  gulp.src('./src/private/*.coffee')
    .pipe(coffeelint({
      "no_backticks": {
        "level": "ignore"
      }
    }))
    .pipe(coffeelint.reporter())
    .pipe(coffee())
    .on('error',function(){});
  if( isMin )
    tmp.pipe(uglify());
  tmp
    .pipe(header(creditText))
    .pipe(gulp.dest('./src/public/'))
    .pipe(browserSync.reload({stream:true}));
});

gulp.task('css',function() {
  var tmp = gulp.src('./src/private/*.sass')
    .pipe( sass().on('error',sass.logError) );

  if( isMin )
    tmp
      .pipe(minifyCss())
      .pipe(header(creditText));
  else
    tmp.pipe(header(creditText));

  tmp.pipe(gulp.dest('./src/public/'))
    .pipe(browserSync.reload({stream:true}));
});

gulp.task('html',function() {
    var tmp = gulp.src('*.jade')
      .pipe(jade())
      .pipe(gulp.dest('./'))
      .pipe(browserSync.reload({stream:true}));
});

gulp.task('build',function() {
  isMin = true;
  gulp.start( 'js','css','html' );
});

gulp.task('default',['js','css','html']);

gulp.task('watch',function() {

  browserSync.init({
    server : {
      baseDir : "./"
    }
  })

  gulp.watch(['./src/private/*.coffee'],['js']);
  gulp.watch(['./src/private/*.less'],['css']);
  gulp.watch(['*.jade'],['html']);
});
