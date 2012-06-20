#!/usr/bin/ruby -w

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'active_record'

ActiveRecord::Base.establish_connection(
	:adapter  => 'mysql',
	:host     => 'localhost',
	:username => 'root',
	:password => 'root',
	:database => 'scrapingWebDb')

class Webscrap < ActiveRecord::Base

end


class WebScrapRecipe
	page = Nokogiri::HTML(open('http://www.simplyrecipes.com/'))
	page.css('div#sitenav')[0]
	recipeIndexUrl = page.css('div#sitenav a' )[2].attribute("href")
	
	def self.url(path)
		return Nokogiri::HTML(open(path))
	end


	def self.insertToDatabase(title,description,ingredient,method)
		scraplink = Webscrap.new(:title=>title,:description=>description,:ingredient=>ingredient,:method=>method)
		scraplink.save	
	end
	

	def self.getData(itemDesc)
 		title=itemDesc.search("//div[@id='entry-individual']/div[2]/span/h1").text
		description=itemDesc.search("//div[@id='recipe-intro']/p").text
		ingredient=itemDesc.search("//div[@id='recipe-ingredients']").text
		method=itemDesc.search("//div[@id='recipe-method']").text
	
		insertToDatabase(title,description,ingredient,method)
	end

	itemPage = url(recipeIndexUrl)

	arrayOfLink=[]
	arrayOfInnerLink=[]
	
	itemPage.search("//div[@id='content']//div[@class='center-module']/p/a").each{|x| arrayOfLink.push(x.attribute("href")) }
	
	for i in 0..10
		innerUrl = url(arrayOfLink[i])
		innerUrl.search("//div[@id='content']//div[@class='archive-entry-title']/a").each{|x| arrayOfInnerLink.push(x.attribute("href")) }
	end
	
	
	for i in 0..20
		itemDesc = url(arrayOfInnerLink[i])
		getData(itemDesc)
	end
	
end
