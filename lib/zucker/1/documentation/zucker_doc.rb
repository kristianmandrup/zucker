# Ruby 1.9, encoding: utf-8
require 'yaml'
require 'coderay'

class ZuckerDoc
  DESCRIPTIONS = {
    'summary'  => 'Summary',
    'why'      => 'Why?',
    'methods'  => 'Methods/Usage',
    'info'     => 'Further information',
    'specification'     => 'Specification',
    'source'   => 'Source',
    'versions' => 'Compatibility',
    'authors'  => 'Authors',
  }
  ORDER   = %w|summary why methods info specification source versions|

  # template vars
  @version = 1

  class << self
    def generate


      cubes = Dir['../descriptions/*'].inject({}) do |res, cube_file; a|
        a = YAML.load_file cube_file
        if a.instance_of? Hash
          res.merge a
        else
          res
        end
      end

      @meta = YAML.load_file 'meta.yaml'

      output = 'zucker_doc.html'
      result = DATA.read

      cubes_html = cubes.map{ |name, hash|
        cube name, hash
      }.join

      # insert cubes
      result.sub! '....', cubes_html
      # substitute vars
      result.gsub! /\.\.([a-z]+)\.\./i do eval "@#$1" end
      # code needs to be codish ;)
      result.gsub! /~~([\w]+?)~~/i, '<code>\1</code>'
      # highlight links
      #...

      File.open output, 'w' do |file|
        file.puts result
      end
    end

  protected

    def cube(name, hash)
      @cube_name = name
      %{ <h3 title="require 'zucker/..version../#{name}'">#{ name }</h3>
         <table class="cube_table"
                id="#{ name }_cube"
                title="require 'zucker/..version../#{name}'"> } +

      ORDER.map{ |th|
        if th == 'specification'   ||
           th == 'source' ||
           td = hash[th]

          "<tr><th>#{ DESCRIPTIONS[th] }</th>" +
          "    <td>#{ send th, td      }</td></tr>"
        end
      }.join +
      '</table>'
    end

    def methods(m)
      m.map{ |name, usage|
        "<h5>#{name}</h5>" +
        "<pre class=\"usage source\" style=\"display:block\">#{ syntax_highlight usage }</pre>"
      }.join
    end

    def info(i)
      convert_html_chars i.join '<br/>'
    end

    def authors(a)
      a.map{ |author|
        author +
        ( (tmp = @meta[author]) ? " | #{ tmp }" : '' )
      }.join '<br/>'
    end

    def why(w)
      if w.is_a? Array
        w = w.map{|e| "<p>#{e}</p>"}.join
      end
      convert_html_chars w
    end

    def summary(s)
      convert_html_chars s
    end

    def versions(v)
      v.join ', '
    end

    def specification(s)
      source_helper(:specification, '../specification/', '_spec')
    end

    def source(s)
      source_helper(:source, '../')
    end

    def source_helper(kind, file_prefix, suffix='')
      %{ <span id="show_#{@cube_name}_#{kind}">(<a href="javascript:show('#{@cube_name}_#{kind}')">show</a>)</span>
         <pre class="source" id="#{@cube_name}_#{kind}">#{
           get_source_file( file_prefix + @cube_name + suffix + '.rb' )
         }</pre> }
    end

    def get_source_file(filename)
      if File.file? filename
        syntax_highlight( File.read(filename).strip )
      else
        '<em>FIXME: missing</em>'
      end
    end

    def syntax_highlight(string)
      #convert_html_chars
      CodeRay.scan(string, :ruby).html
    end

    def convert_html_chars(string, protect_spaces = false)
      string = string.to_s.
        gsub( "\n", '<br/>' ).
        gsub( /⇧(.+?)⇧/, '<code>\1</code>' ).
        gsub( /●(.+?)●/, '<strong>\1</strong>' )

      if protect_spaces
        string.gsub(' ',' ')
      else
        string
      end
    end
  end
end

ZuckerDoc.generate

__END__
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />

  <title>Ruby Zucker ..version..</title>
  <script type="text/javascript">
    var show = function(snippet){
      document.getElementById( snippet ).style.display = 'block'
      if( document.getElementById( 'show_'+snippet ) ){
        document.getElementById( 'show_'+snippet ).style.display = 'none'
      }
    }
  </script>
  <style type="text/css">
body{
  background-color:#aaa;
  color:#111;
  font-family:sans-serif;
}

#world{
  background:#fff;
}

h1, h2, h3, h4, h5, h6{
  margin:0px;
  padding:0px;
}

h1{
  color:#222;
  text-align:center;
  padding:0.5em;
}
h2{
  margin-left:0.5em;
  margin-top:0.8em;
  margin-bottom:0.5em;
}

th{
  width:200px;
  color:#444;
}

p{
  margin:0px;
  margin-bottom:0.5em;
}

p.text{
  margin-left:1.5em;
  margin-right:1em;
}

code{
}

.scode{
  display:block;
  margin:0.8em;
#  margin-right:1.8em;
  padding:0.5em;
  border:1px solid black;
  background:#eee;
}

#.cube_table{
#  display:none;
#}
.cubes{
  margin:0px;
  margin-left:1.5em;
  margin-right:1em;
}

a{
  color:#111;
}

table{
  margin:0.8em;
  margin-top:0.2em;
  padding:0.2em;
  border:1px solid #111;
  background:#eee;
  overflow:auto;
  display:block;
}

th{
  text-align:left;
  vertical-align:top;
  padding-right:3em;
}

td{
  width:100%;
}

li{
  list-style:none;
}


#foot{
  text-align:left;
  padding:0.3em;
  font-size:70%
}
#foot, #foot a{
  color:#444;
}
#smile{
  font-size:150%;
  float:right;
}
#smile a{
  text-decoration:none;
}

.small{
  font-size:70%;
}

code, pre{
  font-face:mono;
  margin:0px;
  padding:0px;
}

.source{
  display:none;
  border:1px solid #005;
  background:#111;
  padding:5px;
  width:98%;

  background-color: #232323;
#  border: 1px solid black;
  font-family: 'Courier New', 'Terminal', monospace;
  color: #E6E0DB;
  padding: 3px 5px;
#  margin-right:1em;
  overflow: auto;
  font-size: 12px;
}

/*railscasts*/
.source .an { color:#E7BE69 }                      /* html attribute */
.source .c  { color:#BC9358; font-style: italic; } /* comment */
.source .ch { color:#509E4F }                      /* escaped character */
.source .cl { color:#FFF }                         /* class */
.source .co { color:#FFF }                         /* constant */
.source .fl { color:#A4C260 }                      /* float */
.source .fu { color:#FFC56D }                      /* function */
.source .gv { color:#D0CFFE }                      /* global variable */
.source .i  { color:#A4C260 }                      /* integer */
.source .il { background:#151515 }                 /* inline code */
.source .iv { color:#D0CFFE }                      /* instance variable */
.source .pp { color:#E7BE69 }                      /* doctype */
.source .r  { color:#CB7832 }                      /* keyword */
.source .rx { color:#A4C260 }                      /* regex */
.source .s  { color:#A4C260 }                      /* string */
.source .sy { color:#6C9CBD }                      /* symbol */
.source .ta { color:#E7BE69 }                      /* html tag */
.source .pc { color:#6C9CBD }                      /* boolean */

  </style>
</head>
<body>
  <div id="world">

    <h1>Ruby Zucker ..version..</h1>
      <h2>What is it?</h2>
      <p class="text">Zucker is the German word for sugar (<a href="http://www.forvo.com/word/zucker/">pronunciation</a>). This gem adds syntactical sugar in the form of independent, lightweight scripts that make Ruby even more beautiful. Read <a href="http://rbjl.net/32-">this blog post</a> for a little introduction!</p>

      <h2>Install</h2>
      <p class="text">
        <code class="scode">gem install zucker # might need sudo</code>
      </p>

      <h2>Usage / Organisation</h2>
      <p class="text">The gem consists of many small snippets, called <em>cubes</em>, which are bundled in <em>packages</em>. Currently, there are two packages available: <strong>default</strong> and <strong>debug</strong>. You can use a package be requiring it in this way:
      <code class="scode">require 'zucker/default'</code>
      and
      <code class="scode">require 'zucker/debug'</code>

      Since there aren't any dependencies within the gem, you could also pick only the cubes you want:

      <code class="scode">require 'zucker/1/egonil'</code>
      </p>
      <p class="text"><em>Please note:</em> To cherry-pick cubes, you have to allude to the gem version you want to use. Future releases of the gem will include all previous versions, so the behaviour of directly required cubes will never change (except for critical bugs).</p>

      <h2 title="require 'zucker/all'">Cubes</h2>
      <div class="cubes">
        ....
      </div>
<br/>
    </div>
  <div id="foot">
    <div id="smile"><a href="http://rbjl.net">J-_-L</a></div>
    This is the Ruby Zucker ..version.. documentation.
    The current version is always available at <a href="http://rubyzucker.info">rubyzucker.info</a>.
    Gem source at <a href="http://github.com/janlelis/zucker">github</a>.
  </div>

</body>
</html>

