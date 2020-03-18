#!/opt/ruby_2.4.0/bin/ruby -w
# coding: utf-8
#
require 'socket'

def 退出(消息)
	puts "#{消息}"
	exit 1
end


脚本参数hash表={}
脚本参数hash表["--file"]="/dev/shm/zero.txt"
ARGV.each {|x|
	正则=%r(--[a-zA-Z0-9]{1,}=.*)
	x.match?(正则) || 退出('请检查你的参数格式是否正确，一般情况下参数要以这种形式：--key=value')
	脚本参数hash表.merge!({"#{x.split("=")[0]}" => "#{x.split("=")[1]}"});
}

传输对象 = 脚本参数hash表["--file"]

File.exist?(传输对象) || 退出("待传输文件是#{传输对象}，但是不存在");
puts "待传输文件是#{传输对象}"

begin
	发送端IP='192.168.137.37'
	发送端PORT=9999
	单次发送数据大小=1*1024*1024  #单位是byte

	服务端 = TCPServer.open(发送端IP,发送端PORT)

	loop {
		Thread.new(服务端.accept) {|客户端|
			puts '新客户端已经连接'

			文件 = File.open(传输对象, 'rb+')
			文件尺寸 = 文件.size
			puts '待发送文件大小 : ' + 文件尺寸.to_s + ' byte'
			发送次数 = 文件尺寸 / 单次发送数据大小
			最后一次发送的数据大小 = 文件尺寸 % 单次发送数据大小

			客户端.puts(文件尺寸) #告知客户端发送的文件大小
			客户端.puts(单次发送数据大小)

			客户端.write(文件.read(文件尺寸)) if 文件尺寸 < 单次发送数据大小

			begin
				发送计数 = 0
				while 发送计数 < 发送次数
				  客户端.write(文件.read(单次发送数据大小))
				  发送计数 += 1
				end
				客户端.write(文件.read(最后一次发送的数据大小))			
			rescue Exception => e
				puts "向客户端发送数据失败，错误详情：#{e.message}"
				exit 1
			end
			puts '所有数据已发送'

			begin
				客户端.close	
				puts '客户端断开'
			rescue Exception => e
				退出("和客户端没有正常完成关闭")
			end
		}
	}	
rescue Exception => e
	puts e.message
end
