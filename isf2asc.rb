#!/usr/bin/ruby
#
# isf data format convert program to ascii
# by knakao
# 
# usage: ruby isf2asc.rb file 
#

def usage
  puts "usage: isf2asc.rb isf_filename"
end

def parseheader(s)
  val = Hash.new;

  s.split(";").each{|i|
    tmp = i.split(" ");
    val[tmp[0]] = tmp[1];
  }
  return val;
end


if(ARGV.size == 0)
  usage;
  exit;
end


f = File.open(ARGV[0], File::RDONLY);
header = f.read.split("#")[0];

skipbytes = header.length + 1;
f.seek(skipbytes);
skipbytes += f.read(1).to_i + 2;
f.seek(skipbytes);

h = parseheader(header);
if((h['BYT_OR'] == "LSB") && (h['BN_FMT'] == "RP"))
  f.close;
  $stderr.puts("error: unsupported byte order.");
  exit;
end

endian = '';
if(h['BYT_OR'] == "MSB")
  endian = (h['BN_FMT'] == "RI") ? "s" : "S";
else
  endian = "n";
end

data = Array.new;

while(!f.eof)
  if(h['BIT_NR'] == "16")
    d = f.read(2).unpack(endian).to_s.to_i;
  else
    d = f.get(1);
  end
  data.push(d);
end
f.close;


x = 0;
data.each{|d|
  y = (d + h['YOFF'].to_f) * h['YMULT'].to_f ;
  printf("%.10f %f\n", x, y);
  x += h['XINCR'].to_f;
}

