module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.initConfig({
    coffee:{
      dev:{
        files:{
          'lib/*.js': 'src/*.coffee'
        }
      },
      test:{
        files:{
          'test/*.js': 'test/*.coffee'
        }
      }
    },
    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          clearRequireCache: true
        },
        src: ['test/*.coffee']
      }
    },

    watch: {
      js: {
        options: {
          spawn: false,
        },
        files: '**/*.coffee',
        tasks: ['default']
      }
    }
  });

  var defaultTestSrc = grunt.config('mochaTest.test.src');
  grunt.event.on('watch', function(action, filepath) {
    grunt.config('mochaTest.test.src', defaultTestSrc);
    if (filepath.match('test/')) {
      grunt.config('mochaTest.test.src', filepath);
    }
  });

  grunt.registerTask('default', 'mochaTest');
};
