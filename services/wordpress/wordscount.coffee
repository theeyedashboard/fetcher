Fetcher = require('../../fetcher')
request = require('request')
cheerio = require('cheerio')
{parseString} = require 'xml2js'

# Return wordcount for a wordpress blog
# Params:
# - site: Wordpress blog url
class WordpressWordscount extends Fetcher

  fetch: =>
    site = @params['site']

    @posts_list = []
    # fetch sitemap.xml and return sub-sitemaps
    @parse_sitemaps site, (sitemaps) =>
      for sitemap in sitemaps
        # fetch sitemap and return posts
        @parse_posts sitemap, (posts) =>
          for post in posts
            console.log post

  # fetch sitemap.xml and return sub-sitemaps urls
  parse_sitemaps: (site, callback) =>
    sitemaps_urls = []
    request "#{site}/sitemap.xml", (error, response, body) =>
      if !error
        parseString body, (err, doc) =>
          for sitemap in doc['sitemapindex']['sitemap']
            sitemap_url = sitemap.loc[0]
            if sitemap_url.indexOf("post") > -1
              sitemaps_urls.push sitemap_url
      callback(sitemaps_urls)

  # fetch sitemap url and return posts
  parse_posts: (sitemap_url, callback) =>
    posts_url = []
    request sitemap_url, (error, response, doc) =>
      if !error
        parseString doc, (err, xmldoc) =>
          for post in xmldoc['urlset']['url']
            post_url = post.loc[0]
            posts_url.push post_url
      callback(posts_url)

  # fetch post url and return words count
  parse_wordscount: (post_url, callback) =>


module.exports = WordpressWordscount
