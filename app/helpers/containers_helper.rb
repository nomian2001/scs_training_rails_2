module ContainersHelper
    MESSAGE1 = "Further evaluation is required. Reason : Packing style"
    MESSAGE2 = "Width exceeds criteria"
    MESSAGE3 = "Length exceeds criteria. Further evaluation by SCM is required"
    MESSAGE4 = "Weight Distribution exceeds criteria. Further evaluation by SCM is required."
    MESSAGE5 = "Height exceeds criteria"
    MESSAGE6 = "COG Height exceeds criteria"
    MESSAGE7 = "Weight concentration exceeds criteria"
    MESSAGE8 = "Length may exceeds container dimension"
    MESSAGE9 = "Weight may exceeds max payload"
    MESSAGE10 = "This acceptance check has to be done again after COG height is determined. This result assuming that the COG is half height of the cargo as you inputted 'TBA' for COG." 

    @items = Item.all

    def handle_flat_track_item(container, result)
        @items.each_with_index do |item,index_of_item|
            packing_style_item = item.packing_style
            if(packing_style_item.upcase == Item::PACKING_STYLE_BARE || packing_style_item.upcase == Item::PACKING_STYLE_SKID)
                update_result_item_ng(result,index_of_item)
                update_message_item(result,ContainersHelper::MESSAGE1,index_of_item)
            end
            check_max_width(item,container,index_of_item,result)
        end
    end

    def check_max_width(item,container,index_of_item, result)
        if(item.width > Item::WIDTH_20FR_MAX || item.width > Item::WIDTH_40FR_MAX)
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE2,index_of_item)
        end
        check_length(item,container,result,index_of_item)
    end
    
    def check_length(item,container,result,index_of_item)
        if(item.length > Item::LENGTH_20FR_MAX || item.length > Item::LENGTH_40FR_MAX)
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE3,index_of_item)
        end
        flat_track_check_weight_distribution(item,container,result,index_of_item)
    end

    def flat_track_check_weight_distribution(item,container,result,index_of_item)
        length_item = item.length
        weight_item = item.weight
        container_type = container.container_type
        if(container_type == Container::FR20)
            flat_track_check_weight_distribution_FR20(item,container_type,result,index_of_item)
        else
            flat_track_check_weight_distribution_FR40(item,container_type,result,index_of_item)
        end
        check_height(item,container,result,index_of_item)
    end

    def flat_track_check_weight_distribution_FR20(item,container_type,result,index_of_item)
        length_item = item.length
        weight_item = item.weight
        start_range = range_length(length_item,container_type)[0]
        end_range = range_length(length_item,container_type)[1]
        if( (weight_item > convert_to_ton(Item::WEIGHT_20FR_MAX[end_range])   )   || 
            (weight_item < convert_to_ton(Item::WEIGHT_20FR_MAX[start_range]) )
        )
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE4,index_of_item)
        end
    end

    def flat_track_check_weight_distribution_FR40(item,container_type,result,index_of_item)
        length_item = item.length
        weight_item = item.weight
        start_range = range_length(length_item,container_type)[0]
        end_range = range_length(length_item,container_type)[1]
        if( (weight_item > convert_to_ton(Item::WEIGHT_40FR_MAX[end_range]) ) ||
            (weight_item < convert_to_ton(Item::WEIGHT_40FR_MAX[start_range]) )
        )
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE4,index_of_item)
        end
    end    

    def check_height(item,container,result,index_of_item)
        height_item = item.height
        if(height_item > Item::MAX_HEIGHT || height_item < Item::MIN_HEIGHT)
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE5,index_of_item)
        end
        flat_track_cog_calculation(item,container,result,index_of_item)
        
    end

    def flat_track_cog_calculation(item,container,result,index_of_item)
        cog_height_type = item.cog_height_type.downcase
        case cog_height_type
        when Item::COG_HEIGHT_TYPE_HALF_OF_CARGO_HEIGHT_OR_LESS
            over_width_check(item,container,result,index_of_item)
        when Item::COG_HEIGHT_TYPE_MANUAL
            over_width_check(item,container,result,index_of_item)
        when Item::COG_HEIGHT_TYPE_TBA
            update_message_container(result,ContainersHelper::MESSAGE10)
            over_width_check(item,container,result,index_of_item)
        end
    end    

    def over_width_check(item,container,result,index_of_item)
        width_item = item.width
        container_type = container.container_type
        if(container_type == Container::FR20)
            over_width_check_FR20(item,container,result,index_of_item)
        else
            over_width_check_FR40(item,container,result,index_of_item)
        end
    end

    def over_width_check_FR20(item,container,result,index_of_item)
        width_item = item.width
        if(width_item <= Item::WIDTH_20FR)
            cog_height_check_2(item,container,result,index_of_item)
        else
            cog_height_check_1(item,container,result,index_of_item)
        end 
    end

    def over_width_check_FR40(item,container,result,index_of_item)
        width_item = item.width
        if(width_item <= Item::WIDTH_40FR)
            cog_height_check_2(item,container,result,index_of_item)
        else
            cog_height_check_1(item,container,result,index_of_item)
        end 
        
    end

    def cog_height_check_2(item,container,result,index_of_item)
        width_item = item.width
        total_height = get_total_height_of_item_in_container()
        cog_value = (total_height/2).to_f
        
        if(cog_value > width_item * 0.865)
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE6,index_of_item)
        end
        update_result_item_ok(result,index_of_item)
        total_length_check(item,container,result,index_of_item)
    end
    
    def cog_height_check_1(item,container,result,index_of_item)
        width_item = item.width
        total_height = get_total_height_of_item_in_container()
        cog_value = (total_height/2).to_f
        
        if(cog_value > Item::COG_HEIGHT_FLAT_TRACK)
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE6,index_of_item)
        end
        update_result_item_ok(result,index_of_item)
        total_length_check(item,container,result,index_of_item)
    end

    def get_total_height_of_item_in_container
        total_height = 0
        @items.each do |item|
            if(item.cog_height_type.downcase == Item::COG_HEIGHT_TYPE_MANUAL)
                height_item = item.height
            else
                height_item = item.height*0.5
            end
            if(total_height < height_item)
                total_height = height_item
            end
        end
        return total_height
    end

    def range_length(number,container_type)
        if(container_type == Container::FR20)
            divide = (number/50).to_i
            start_range = 50 * divide
            end_range = 50 * (divide + 1)
        else
            divide = (number/100).to_i
            start_range = 100 * divide
            end_range = 100 * (divide + 1)
        end
        
        return [start_range,end_range]
    end

    def handle_open_top_item(container,result)
        @items.each_with_index do |item,index_of_item|
            packing_style_item = item.packing_style
            if(packing_style_item.upcase == Item::PACKING_STYLE_BARE)
                update_result_item_ng(result,index_of_item)
                update_message_item(result,ContainersHelper::MESSAGE1,index_of_item)
            end
            open_top_cog_height_calculation(item,container,result,index_of_item)
        end
    end

    def open_top_cog_height_calculation(item,container,result,index_of_item)
        cog_height_type = item.cog_height_type.downcase
        case cog_height_type
        when Item::COG_HEIGHT_TYPE_TBA
            update_message_container(result,ContainersHelper::MESSAGE10)
            
            open_top_cog_value_check(item,container,result,index_of_item)
        when Item::COG_HEIGHT_TYPE_MANUAL
            open_top_cog_value_check(item,container,result,index_of_item)
            
        when Item::COG_HEIGHT_TYPE_HALF_OF_CARGO_HEIGHT_OR_LESS
            open_top_cog_value_check(item,container,result,index_of_item)
           
        end
    end

    def open_top_cog_value_check(item,container,result,index_of_item)
        cog_height_type = item.cog_height_type.downcase
        if( (cog_height_type == Item::COG_HEIGHT_TYPE_HALF_OF_CARGO_HEIGHT_OR_LESS) ||
            (cog_height_type == Item::COG_HEIGHT_TYPE_TBA)
        )
            cog_value = item.height*0.5
        else
            cog_value = item.height
        end
        
        if(cog_value > Item::COG_HEIGHT_OPEN_TOP)
            update_result_item_ng(result,index_of_item)
            update_message_item(result, ContainersHelper::MESSAGE6,index_of_item)
        end
        open_top_weight_distribution_check(item,container,result,index_of_item)
    end

    def open_top_weight_distribution_check(item,container,result,index_of_item)
        weight_item = item.weight
        length_item = item.length.to_f
        length_item = convert_to_meter(length_item)
        max_weight_distribution = (weight_item / length_item).to_f
        
        container_type = container.container_type
        if((container_type == Container::OT20 && max_weight_distribution > Item::OT_WEIGHTDIST_20OT_MAX) || 
            (container_type == Container::OT40 && max_weight_distribution > Item::OT_WEIGHTDIST_40OT_MAX)
        )
            update_result_item_ng(result,index_of_item)
            update_message_item(result,ContainersHelper::MESSAGE7,index_of_item)
        end
        update_result_item_ok(result,index_of_item)
        total_length_check(item,container,result,index_of_item)
    end

    def total_length_check(item,container,result,index_of_item)
        total_length = total_length_in_container()
        container_type = container.container_type
        case container_type
        when Container::FR20
            if(total_length > Item::TOTAL_LENGTH_20FR)
                update_message_container(result,ContainersHelper::MESSAGE8)
            end
        when Container::FR40
            if(total_length > Item::TOTAL_LENGTH_40FR)
                update_message_container(result,ContainersHelper::MESSAGE8)
            end
        when Container::OT20
            if(total_length > Item::TOTAL_LENGTH_20OT)
                update_message_container(result,ContainersHelper::MESSAGE8)
            end
        when Container::OT40
            if(total_length > Item::TOTAL_LENGTH_40OT)
                update_message_container(result,ContainersHelper::MESSAGE8)
            end
        end
        total_weight_check(item,container,result)
    end

    def total_weight_check(item,container,result)
        total_weight = total_weight_in_container()
        container_type = container.container_type
        case container_type
        when Container::FR20
            if(total_weight > Item::TOTAL_WEIGHT_20FR)
                update_message_container(result,ContainersHelper::MESSAGE9)
            end
        when Container::FR40
            if(total_weight > Item::TOTAL_WEIGHT_40FR)
                update_message_container(result,ContainersHelper::MESSAGE9)
            end
        when Container::OT20
            if(total_weight > Item::TOTAL_WEIGHT_20OT)
                update_message_container(result,ContainersHelper::MESSAGE9)
            end
        when Container::OT40
            if(total_weight > Item::TOTAL_WEIGHT_40OT)
                update_message_container(result,ContainersHelper::MESSAGE9)
            end
        end
        update_total_size_container(result)
        update_total_result_container(result)
        update_final_conclusion(result)
    end

    def total_weight_in_container
        total_weight = 0
        @items = Item.all
        @items.each do |item|
            weight_item = item.weight
            total_weight = total_weight + weight_item
        end
        return total_weight
    end

    def total_length_in_container
        total_length = 0
        @items = Item.all
        @items.each do |item|
            length_item = item.length
            total_length = total_length + length_item
        end
        return total_length
    end

    def update_message_item(result,message,index_of_item)
        if(result["items"][index_of_item].has_key?("remark"))                   #check if inside of item has key "remark" or not
            if(!result["items"][index_of_item]["remark"].include?(message))             #check if message is existed in remark
                result["items"][index_of_item]["remark"].append(message)
            end
        else
            result["items"][index_of_item]['remark'] = [message]
        end
    end

    def update_result_item_ng(result,index_of_item)
        result["items"][index_of_item]["result"] = Item::ITEM_RESULT_NG 
    end

    def update_result_item_ok(result,index_of_item)
        if(!result["items"][index_of_item].has_key?("result"))                #if there is no ng => item is ok
            result["items"][index_of_item]["result"] = Item::ITEM_RESULT_OK
        end
    end


    def update_message_container(result,message)
        update_total_size_container(result)
        update_total_result_container(result)
        update_total_remark_container(result,message)
        update_final_conclusion(result)
    end

    def update_total_size_container(result)
        result['total_length'] = total_length_in_container()
        result['total_weight'] = total_weight_in_container()
    end

    def update_total_result_container(result)
        result['items'].each do |item|
            if(item['result'] == Item::ITEM_RESULT_NG)
                result['total_result'] = Container::CONTAINER_RESULT_NG
                break
            end
            result['total_result'] = Container::CONTAINER_RESULT_OK 
        end
    end

    def update_total_remark_container(result,message)
        if(result.has_key?('total_remark'))                     #check if inside of container has key "total_remark" or not
            if(!result['total_remark'].include?(message))         #check if message is existed in key "total_remark"
                result['total_remark'].append(message)
            end
        else
            result['total_remark'] = [message]
        end
    end

    def update_final_conclusion(result)
        if(result['total_result'] == Container::CONTAINER_RESULT_NG)
            result['final_conclusion'] = Container::CONTAINER_RESULT_NG
        else
            result['final_conclusion'] = Container::CONTAINER_RESULT_OK
        end 
    end

    def convert_to_ton(weight)
        weight = (weight/1000).to_f
    end

    def convert_to_meter(length)
        length = (length/100).to_f
    end
end
