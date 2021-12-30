class Container < ApplicationRecord
    validates :container_type, presence: true
    FR20 = "FR20"
    FR40 = "FR40"
    OT20 = "OT20"
    OT40 = "OT40"

    CONTAINER_RESULT_NG = "NG"
    CONTAINER_RESULT_OK = "OK"
    CONTAINER_RESULT_TBA = "TBA"
    
end
