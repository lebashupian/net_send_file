#!/opt/ruby_2.2.3/bin/ruby -w
# coding: utf-8
#
require 'socket'


服务端IP='192.168.137.37'
服务端PORT=9999

线程=Thread.new {
	文件名称 = '/tmp/1.txt'

	begin
		服务端 = TCPSocket.open(服务端IP, 服务端PORT)
		文件 = File.open(文件名称, 'wb+')

		文件尺寸 = 服务端.readline.to_i # 第一个数据是服务器传回的文件大小
		文件传输单元 = 服务端.readline.to_i
		puts "服务器告知的文件尺寸是:#{文件尺寸}"
		puts "服务器告知的传输尺寸是:#{文件传输单元}"
		传输次数 = 文件尺寸 / 文件传输单元
		剩余数据 = 文件尺寸 % 文件传输单元
		传输次数.times {|x|
			p x
			数据 = 服务端.read(文件传输单元)
			文件.write(数据)	  			
		}
		文件.write(服务端.read(剩余数据)) if 剩余数据 != 0
		文件.close
		puts "文件传输完毕"
	rescue Exception => e
		puts "发生错误:#{e.message}"
	end

}
线程.join
