//
//  Task.swift
//  taskApp
//
//  Created by 上田大河 on 2022/11/06.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
    
    @objc dynamic var category = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
