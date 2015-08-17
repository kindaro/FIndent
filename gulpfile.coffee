gulp = require ('gulp')
coffee = require ('gulp-coffee')
jade = require ('gulp-jade')
stylus = require ('gulp-stylus')
yaml = require ('gulp-yaml')
sass = require ('gulp-sass')
minifyHTML = require ('gulp-minify-html')
pages = require ('gulp-gh-pages')

gulp.task 'default', ['coffee', 'jade', 'styl', 'yaml']

gulp.task 'watch',
    ->
        gulp.watch './src/**', ['default']

gulp.task 'gulpfile',
    ->
        gulp.src './gulpfile.coffee'
        .pipe coffee {bare: true}
        .pipe gulp.dest './'

gulp.task 'jade',
    ->
        gulp.src ['./src/**/*.jade', '!./src/_*/**/*.jade']
        .pipe jade {pretty: true}
        .pipe minifyHTML { }
        .pipe gulp.dest './build'

gulp.task 'coffee',
    ->
        gulp.src './src/**/*.coffee'
        .pipe coffee {bare: true}
        .pipe gulp.dest './build'

gulp.task 'styl',
    ->
        gulp.src './src/**/*.styl'
        .pipe stylus {}
        .pipe gulp.dest './build'

gulp.task 'yaml',
    ->
        gulp.src './src/**/*.yml'
        .pipe yaml { space: 4 }
        .pipe gulp.dest './build'

gulp.task 'inuit',
    ->
        gulp.src './inuit.css-web-template/css/style.scss'
        .pipe sass {}
            .on 'error', sass.logError
        .pipe gulp.dest './build'

gulp.task 'pages',
    ->
        gulp.src './build/**/*'
            .pipe pages {}
