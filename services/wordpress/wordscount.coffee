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
    @wordscount = 0

    # @parse_wordscount "http://zestprod.com/2015/08/19/stop-building-apps-that-users-wont-give-a-shit-about/", (wordscount) =>
    #   console.log wordscount

    # fetch sitemap.xml and return sub-sitemaps
    @parse_sitemaps site, (sitemaps) =>

      # fetch sitemap and return posts
      @parse_posts sitemaps, (posts) =>
        posts_parsing = 0
        for post in posts
          posts_parsing++
          @parse_wordscount post, (wordscount) =>
            posts_parsing--
            @wordscount += wordscount
            if posts_parsing == 0
              console.log @wordscount
              @return_value String(@wordscount)

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

  # fetch all sitemaps url and return all posts
  parse_posts: (sitemaps, callback) =>
    posts_url = []
    sitemaps_parsing = 0
    for sitemap_url in sitemaps
      sitemaps_parsing++
      request sitemap_url, (error, response, doc) =>
        sitemaps_parsing--
        if !error
          parseString doc, (err, xmldoc) =>
            for post in xmldoc['urlset']['url']
              post_url = post.loc[0]
              posts_url.push post_url
        callback(posts_url) if sitemaps_parsing == 0

  # fetch post url and return words count
  parse_wordscount: (post_url, callback) =>
    wordscount = 0
    request post_url, (error, response, doc) =>
      if !error
        $ = cheerio.load(doc)
        title = $('.entry-title').html()
        content = $('.entry-content').html()
        wordscount = @word_count(title) + @word_count(content)
      callback(wordscount)

  # count words in a text
  word_count: (text) =>
    text = text.replace(/<(?:.|\n)*?>/gm, '') # exclude HTML tags
    text = text.replace(/(^\s*)|(\s*$)/gi,"") # exclude start and end white-space
    text = text.replace(/[ ]{2,}/gi," ") # 2 or more space to 1
    text = text.replace(/\n /,"\n") # exclude newline with a start spacing
    return text.split(' ').length


module.exports = WordpressWordscount
