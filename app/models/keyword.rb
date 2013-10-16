# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: keywords
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  ancestry   :string(255)
#  is_child   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Keyword < ActiveRecord::Base
  include Redis::Objects
  include Cacheable
  has_ancestry
  attr_accessible :ancestry, :title,:is_child
  hash_key :children_nodes

  model_cache do
    with_key   
    with_attribute :title                      
  end

#begin 初始化数据库和redis
  def init_keywords_to_db_and_redis
  	destroy_descendant_nodes_in_db_and_reids
  	File.open(File.join(Rails.public_path,'keyword.txt'), "r") do |file|  
	    file.each_line do |line| 
	    	keywords = line.chomp
        next if keywords.blank?
	    	root_node = find_create_node(keywords[0])
	      init_children(root_node,keywords[1..(keywords.length-1)] )
	    end  
    end 
    update_chldren_nodes_in_redis
  end 

  def destroy_descendant_nodes_in_db_and_reids
    destroy_chldren_nodes_in_redis
    descendants.destroy_all
  end

  def destroy_chldren_nodes_in_redis
    descendants.each do |node|
      node.children_nodes.clear
    end
    self.children_nodes.clear
  end

  def update_chldren_nodes_in_redis()
    Keyword.all.each do |parent|
      parent.children.each do |child|
        parent.children_nodes["#{child.title}"] = child.id
      end
    end
  end

  def find_create_node(key)
  	children.find_or_create_by_title(:title => key)
  end

  def init_children(parent,keys)
  	keys.each_char do |key|
  		if key == keys.last
  			parent = parent.children.create(:title=>key,:is_child=>true)
  		else
  			parent = parent.children.create(:title=>key)
  		end
  	end
  end
#end 初始化数据库和redis


#begin 开始查找字符
  def find_node(key)
    if id = children_nodes[key]
     self.class.find_cached(id)
    end
  end

  def self.root_node
    find_cached_by_title('root')
  end

  def self.find_matched_keywords(text)
  	words = []
  	word = ''
  	node = root_node
  	pos = 0
  	while(pos < text.length)
      key = text[pos]
  		node1 = node.find_node(key)
  		if node1.nil?
  			word = ''
        pos += 1 if node.root?
  			node = root_node
  		elsif node1.is_child == true
  			word << key
  			words << word
  			word = ''
  			node = root_node
        pos += 1
  		else
  			word << key
  			node = node1
        pos += 1
  		end
  	end
  	words.uniq
  end

  def self.test_keywords(n)
    content = '李建国在讲话中指出，习仲勋同志的一生，是革命的一生，光辉战斗的一生，全心全意为人民服务的一生。他为中国人民解放事业和新中国诞生，为社会主义革命、建设、改革事业，为中国特色社会主义事业，顽强奋斗，建立了不可磨灭的历史功勋。他的光辉业绩和卓越贡献，深深铭记在我们心中。他的革命精神和崇高品格，永远值得我们学习和怀念。今天我们纪念习仲勋同志，就是要学习他始终不渝坚守共产主义理想信念，一生忠于党、忠于人民的高尚品格，增强中国特色社会主义道路自信、理论自信、制度自信，坚持党的基本理论、基本路线、基本纲领、基本经验、基本要求，坚定不移走中国特色社会主义道路；就是要学习他始终坚持解放思想、实事求是、与时俱进，一生为党和人民事业呕心沥血的革命精神，坚持党的思想路线，继续解放思想，不断开拓创新，以全面深化改革的新的实践，夺取中国特色社会主义新胜利；就是要学习他始终坚持马克思主义群众观点和党的群众路线，一生热爱人民、心系群众的优良作风，坚决反对形式主义、官僚主义、享乐主义和奢靡之风，真正做到一切为了群众、一切依靠群众，立党为公、执政为民，不断夯实党执政兴国的牢固根基；就是要学习他始终保持共产党人的政治本色，一生胸怀坦荡、光明磊落的崇高风范，克己奉公、勤政为民、廉洁自律，以优良作风凝聚起建设中国特色社会主义的强大力量本周四，上海兴安子公司的胡总将给我们带来关于《软件的本质—企业的智慧》的主题分享。胡总曾多年从事管理咨询及企业管理工 作，对管理理论及软件系统有深入的研究。曾经在LPDT交流会上做过〈复杂性业务系统〉的分享，现场各领导及产品负责人均温家宝受益非浅。江泽民这次也一定会带给大家全新的 理念和不同的体验，野人谷甩棍让我们试目以待。。。'
    Benchmark.bm do |x|
      x.report { n.times { find_matched_keywords content } }
    end
  end
#end 开始查找字符
end
