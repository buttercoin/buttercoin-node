module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-simple-mocha');
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
    simplemocha: {
      dev:{
        src: 'test/*.coffee',
        options: {
          reporter: 'spec',
          slow: 200,
          timeout: 1000
        }
      }
    }
  });
};
