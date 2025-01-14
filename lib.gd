#region ALL
extends Node


#region ALL -> VARS
#region ALL -> VARS -> ROOKIE VARS
var unix_day: int = 60*60*24
var unix_hour: int = 60*60
@warning_ignore("untyped_declaration")
var file
var temp_dict: Dictionary
var temp_temp_dict: Dictionary
var path_start: String = "user://CAPSULES/"
var path_end: String = ".txt"
var threshold_hours: int
var temp_array: Array = []
var urgent: String = "СРОЧНО "
var temp_task_id: int
var temp_text: String = ""
var temp_capsule_id: int
var temp_temp_capsule_id: int
var temp_num: int = 0
var temp_bool: bool
var dev_passgen_code: int = 3066
var new_capsule_dict: Dictionary = {"capsule" = 0, "occupied" = false,\
"name" = "ПУСТАЯ КАПСУЛА", "locker" = 0, "door" = 0}
var new_guest_dict: Dictionary = {"capsule" = 0, "occupied" = true,\
"name" = "ПУСТАЯ КАПСУЛА", "locker" = 0, "door" = 0}
var hours_for_reptasks:int = 10
var other_payment_array_size: int = 12
var cash_register_shifts_array: Array
var loading_done: bool = false

var temp_sale_num: int
#endregion

#region ALL -> VARS -> EXPIRY VARS
var expiry_screen_show: bool = true
var global_frame_timer: Dictionary = {"count":24*60*60*24,"counting":true}
var crash_debug_counter: int = 0
var chance_of_crash_secs: int = 60 * 60
var chance_of_crash: float = 1.0/(Engine.max_fps * chance_of_crash_secs)
var days_expired_to_start_crashing: int = -8
var days_expired_to_break_exit_button: int = -6
var days_expired_to_move_exit_button: int = -12

var expiry_day: int = 1
var expiry_month: int = 12
var expiry_year: int = 2024
#endregion

var random_checker_scores: Array[float] = []

#endregion


#region ALL -> FUNCS


#region ALL -> FUNCS -> CASH
func cash_return_all_money_actions_in_current_shift() -> Array:
    return cash_register_shifts_array[-1]["money_actions"]


func cash_return_all_cash_money_actions_in_current_shift() -> Dictionary:
    var amounts: Array[int] = []
    var comments: Array[String] = []
    for a: Dictionary in cash_register_shifts_array[-1]["money_actions"]:
        if a["money_action"]["cash"] > 0:
            amounts.append(a["money_action"]["cash"])
            comments.append(a["comment"])
    return {"amounts" : amounts, "comments" : comments}


func cash_add_return(cash: int = 0,\
credit: int = 0, qr: int = 0, transfer: int = 0,\
commentary: String = "ВОЗВРАТ БЕЗ КОММЕНТАРИЯ") -> void:
    cash_register_shifts_array[-1]["money_actions"].append({"money_action" = {}})
    cash_register_shifts_array[-1]["money_actions"][-1]["datetime"] =\
    Time.get_datetime_dict_from_system()
    cash_register_shifts_array[-1]["money_actions"][-1]["money_action"] =\
    {"cash" = - cash, "credit" = - credit, "qr" = - qr, "transfer" = - transfer}
    cash_register_shifts_array[-1]["money_actions"][-1]["commentary"] =\
    commentary
    


func cash_add_payment(cash: int = 0,\
credit: int = 0, qr: int = 0, transfer: int = 0,\
commentary: String = "ОПЛАТА БЕЗ КОММЕНТАРИЯ") -> void:
    cash_register_shifts_array[-1]["money_actions"].append({"money_action" = {}})
    cash_register_shifts_array[-1]["money_actions"][-1]["datetime"] =\
    Time.get_datetime_dict_from_system()
    cash_register_shifts_array[-1]["money_actions"][-1]["money_action"] =\
    {"cash" = cash, "credit" = credit, "qr" = qr, "transfer" = transfer}
    cash_register_shifts_array[-1]["money_actions"][-1]["commentary"] =\
    commentary


func cash_close_shift() -> void:
    if typeof(cash_register_shifts_array[-1]["closed"]) == TYPE_BOOL:
        cash_register_shifts_array[-1]["closed"] = Time.get_datetime_dict_from_system()
        cash_register_shifts_array[-1]["cash_on_close"] = cash_return_current_cash()
    


func cash_return_current_cash() -> int:
    var total: int = cash_register_shifts_array[-1]["cash_on_open"]
    for a: Dictionary in cash_register_shifts_array[-1]["money_actions"]:
        total = total + a["money_action"]["cash"]
    return total


func cash_open_shift(cash_on_open: int) -> void:
    if typeof(cash_register_shifts_array[-1]["closed"]) != TYPE_BOOL:
        cash_register_shifts_array.append({"opened":Time.get_datetime_dict_from_system(),\
        "closed":false,\
        "cash_on_open":cash_on_open,"cash_on_close":false,\
        "money_actions":[]})


func cash_file_max_256() -> void:
    if cash_register_shifts_array.size() > 256:
        cash_register_shifts_array.pop_front()
    else:pass


func cash_save(testing: bool = false) -> void:
    var f: FileAccess
    if !testing:
        f = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER", FileAccess.WRITE)
    else:
        f = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER_testing", FileAccess.WRITE)
    f.store_string(JSON.stringify(cash_register_shifts_array, "    "))
    f.close()


func cash_load(testing: bool = false) -> void:
    var f: FileAccess
    if !testing:
        f = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER", FileAccess.READ)
    else:
        f = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER_testing", FileAccess.READ)
    cash_register_shifts_array = JSON.parse_string(f.get_as_text())
    f.close()


#func cash_save() -> void:
    #var f: FileAccess = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER", FileAccess.WRITE)
    #f.store_string(JSON.stringify(cash_register_shifts_array, "    "))
    #f.close()
#
#
#func cash_load() -> void:
    #var f: FileAccess = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER", FileAccess.READ)
    #cash_register_shifts_array = JSON.parse_string(f.get_as_text())
    #f.close()


func cash_make_file(testing: bool = false) -> void:
    var f: FileAccess
    if !testing:
        f = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER", FileAccess.WRITE)
    else:
        f = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER_testing", FileAccess.WRITE)
    var money_action: Dictionary = {"cash":0,"credit":0,"qr":0,"transfer":0}
    var money_actions_array: Array = [{\
    "datetime" = Time.get_datetime_dict_from_system(),\
    "money_action" = money_action,\
    "commentary" = "ПУСТАЯ ОПЛАТА (СОЗДАНИЕ НОВОЙ БАЗЫ СМЕН)"}]
    var shift: Dictionary = \
    {"opened":Time.get_datetime_dict_from_system(),\
    "closed":Time.get_datetime_dict_from_system(),\
    "cash_on_open":0,"cash_on_close":0,\
    "money_actions":money_actions_array}
    var base_array_of_shifts: Array = [shift]
    f.store_string(JSON.stringify(base_array_of_shifts, "\t"))
    f.close()


#func cash_make_file() -> void:
    #var f: FileAccess = FileAccess.open("user://CAPSULES/OTHER/CASH_REGISTER", FileAccess.WRITE)
    #var money_action: Dictionary = {"cash":0,"credit":0,"qr":0,"transfer":0}
    #var money_actions_array: Array = [{\
    #"datetime" = Time.get_datetime_dict_from_system(),\
    #"money_action" = money_action,\
    #"commentary" = "ПУСТАЯ ОПЛАТА (СОЗДАНИЕ НОВОЙ БАЗЫ СМЕН)"}]
    #var shift: Dictionary = \
    #{"opened":Time.get_datetime_dict_from_system(),\
    #"closed":Time.get_datetime_dict_from_system(),\
    #"cash_on_open":0,"cash_on_close":0,\
    #"money_actions":money_actions_array}
    #var base_array_of_shifts: Array = [shift]
    #f.store_string(JSON.stringify(base_array_of_shifts, "\t"))
    #f.close()
#endregion


func random_checker(new_value: float) -> float:
    random_checker_scores.append(new_value)
    return add_all_floats(random_checker_scores)/float(random_checker_scores.size())


func add_all_floats(array: Array) -> float:
    var i: int = 0
    var out: float = 0
    while i < array.size():
        out += array[i]
        i += 1
    return out


func random_percent(percent: int) -> bool:
    var randf_var: float = randf()
    if randf_var < (float(percent)/100.0):
        return true
    else: return false



func delete_capsule_one_file() -> void:
    print("opening user://CAPSULES")
    var a: DirAccess = DirAccess.open("user://CAPSULES")
    print("removing 1.txt")
    a.remove("1.txt")


func make_capsule_files():
    var path_beginning = "user://CAPSULES/"
    var path_number_int:int = 0
    var path_number_string = ""
    var path_ending = ".txt"
    var full_path = ""
    var the_file
    var capsule_key

    while (path_number_int<49):
        path_number_int = path_number_int + 1
        path_number_string = String.num(path_number_int)
        print("making the_file " + path_number_string)
        full_path = path_beginning + path_number_string + path_ending
        path_number_int = path_number_string.to_int()
        print("full path is " + full_path)
        the_file = FileAccess.open(full_path, FileAccess.WRITE)
        capsule_key = lib.new_capsule_dict
        capsule_key["capsule"] = path_number_int
        capsule_key = JSON.stringify(capsule_key)
        the_file.store_string(capsule_key)
        the_file.close()
        print("the_file " + path_number_string + " created")
        lib.new_payment_history_key("БАЗА ДАННЫХ КАПСУЛ СБРОШЕНА")


func date_expiry_daysleft():
    @warning_ignore("integer_division")
    return (((Time.get_unix_time_from_datetime_dict({"day":expiry_day,"month":expiry_month,"year":expiry_year}))-(Time.get_unix_time_from_datetime_dict(Time.get_date_dict_from_system())))/unix_day)-1


func swap_reptasks_and_save(one,two):
    var arr = ["",""]
    lib.get_temp_array_from_file("OTHER/REPTASKS")
    if (one < 0 or two < 0 or one+1 >= lib.temp_array.size() or two+1 >= lib.temp_array.size()):
        pass
    else:
        arr[0] = lib.temp_array[one]
        arr[1] = lib.temp_array[one + 1]
        lib.temp_array[one] = lib.temp_array[two]
        lib.temp_array[one + 1] = lib.temp_array[two + 1]
        lib.temp_array[two] = arr[0]
        lib.temp_array[two + 1] = arr[1]

    lib.write_temp_array_to_file("OTHER/REPTASKS")


func c(path_string):
    get_tree().change_scene_to_file(path_string)


func swap_places(capsule_one, capsule_two):
    get_temp_dict_from_file(num_to_string(capsule_one))
    temp_temp_dict = temp_dict
    temp_temp_dict.capsule = capsule_two
    get_temp_dict_from_file(num_to_string(capsule_two))
    temp_dict.capsule = capsule_one
    save_temp_dict_to_file(num_to_string(capsule_one))
    temp_dict = temp_temp_dict
    save_temp_dict_to_file(num_to_string(capsule_two))


func add_new_other_payment(other_payment_string):
    get_temp_array_from_file("OTHER/OTHER PAYMENTS")
    temp_array = [other_payment_string] + temp_array
    if (temp_array.size() > other_payment_array_size):
        temp_array.resize(temp_array.size() - 1)
    else:
        pass
    write_temp_array_to_file("OTHER/OTHER PAYMENTS")


func return_day_for_reptasks():
    return (sub_hours(Time.get_datetime_dict_from_system(), hours_for_reptasks)).day


func tasks_from_reptasks():
    temp_task_id = 0
    get_temp_array_from_file("OTHER/REPTASKS")
    if (temp_array.size() > 0):
        while (temp_task_id < temp_array.size()):
            get_temp_array_from_file("OTHER/REPTASKS")
            if (temp_array[temp_task_id + 1] == return_day_for_reptasks()):
                pass
            else:
                temp_array[temp_task_id + 1] = return_day_for_reptasks()
                write_temp_array_to_file("OTHER/REPTASKS")
                var new_array = [temp_array[temp_task_id]]
                get_temp_array_from_file("OTHER/ДЕЛА")
                temp_array = temp_array + new_array
                write_temp_array_to_file("OTHER/ДЕЛА")
            if (temp_task_id == 0):
                temp_task_id = 2
                get_temp_array_from_file("OTHER/REPTASKS")
            else:
                temp_task_id = temp_task_id + 2
                get_temp_array_from_file("OTHER/REPTASKS")
    else:
        pass


func make_loan(dict):
    dict.day = dict.due_day
    dict.month = dict.due_month
    dict.year = dict.due_year
    dict.weekday = dict.due_weekday
    dict.merge(return_due_date_dict_from_date_dict(dict, 1),true)


func return_standartified_due_date_dict(due_date_dict):
    var standartified_dict = {}
    if (lib.num_to_string(due_date_dict["due_day"]).length()<2):
        standartified_dict["due_day"] = "0"+lib.num_to_string(due_date_dict["due_day"])
    else:
        standartified_dict["due_day"] = lib.num_to_string(due_date_dict["due_day"])
    if (lib.num_to_string(due_date_dict["due_month"]).length()<2):
        standartified_dict["due_month"] = "0"+lib.num_to_string(due_date_dict["due_month"])
    else:
        standartified_dict["due_month"] = lib.num_to_string(due_date_dict["month"])
    return standartified_dict["due_day"]+"."+standartified_dict["due_month"]


func return_standartified_date_dict(date_dict):
    var standartified_dict = {}
    if (lib.num_to_string(date_dict["day"]).length()<2):
        standartified_dict["day"] = "0"+lib.num_to_string(date_dict["day"])
    else:
        standartified_dict["day"] = lib.num_to_string(date_dict["day"])
    if (lib.num_to_string(date_dict["month"]).length()<2):
        standartified_dict["month"] = "0"+lib.num_to_string(date_dict["month"])
    else:
        standartified_dict["month"] = lib.num_to_string(date_dict["month"])
    return standartified_dict["day"]+"."+standartified_dict["month"]


func int_to_float(int_num):
    return float(int_num)


func float_to_int(float_num):
    return int(float_num)


func return_dev_password():
    #seed(string_to_num(num_to_string(float_to_int(Time.get_unix_time_from_system())*dev_passgen_code).substr(0,6)))
    #return num_to_string(randi_range(10000,19999)).substr(1,4)
    return lib.num_to_string(lib.dev_passgen_code)


func check_deadline_in_capsule(capsule_id):
    get_temp_dict_from_file(capsule_id)
    var due_unix = Time.get_unix_time_from_datetime_dict(return_date_dict_from_due_date_dict(temp_dict))
    var current_unix = Time.get_unix_time_from_system()
    if (current_unix > due_unix):
        return true
    else:
        return false


func new_payment_history_key(string_key):
    file = FileAccess.open("user://CAPSULES/OTHER/PAYMENTS/" + num_to_string(int(Time.get_unix_time_from_system())) + "                " + string_key, FileAccess.WRITE)
    file.close()


func add_new_task(task_string):
    get_temp_array_from_file("OTHER/ДЕЛА")
    lib.temp_array = lib.temp_array + [task_string]
    new_payment_history_key("ДОБАВЛЕНО НОВОЕ ДЕЛО " + task_string)
    lib.write_temp_array_to_file("OTHER/ДЕЛА")


func convert_to_time_dict(day, month, year, weekday):
    return {day = day, month = month, year = year, weekday = weekday}


func check_if_any_urgent_in_tasks():
    get_temp_array_from_file("OTHER/ДЕЛА")
    temp_task_id = 0
    var return_bool = false
    while (temp_task_id < temp_array.size()):
        if (temp_array[temp_task_id].begins_with("СРОЧНО") || temp_array[temp_task_id].begins_with("срочно")):
            return_bool = true
        temp_task_id = temp_task_id + 1
    return return_bool


func check_if_is_urgent(the_string):
    if (the_string.begins_with("СРОЧНО ") || the_string.begins_with("срочно ")):
        return true
    else:
        return false


func make_string_urgent(the_string):
    return urgent + the_string


func make_string_unurgent(the_string):
    return the_string.trim_prefix("СРОЧНО ").trim_prefix("срочно ")


func get_temp_array_from_file(file_name_string):
    file = FileAccess.open(path_start+file_name_string+".txt", FileAccess.READ)
    temp_array = JSON.parse_string(file.get_as_text())
    file.close()


func write_temp_array_to_file(file_name_string):
    file = FileAccess.open(path_start+file_name_string+path_end, FileAccess.WRITE)
    file.store_string(JSON.stringify(temp_array))
    print("saved to file "+file_name_string+":")
    print(JSON.stringify(temp_array))
    file.close()


func write_due_date_dict_to_file(file_name):
    get_temp_dict_from_file(file_name)
    temp_dict.merge(return_due_date_dict_from_date_dict(temp_dict, temp_dict["days_paid"]), true)
    save_temp_dict_to_file(file_name)


func return_date_dict_from_due_date_dict(date_dict):
    var year = date_dict["due_year"]
    var month = date_dict["due_month"]
    var day = date_dict["due_day"]
    var weekday = date_dict["due_weekday"]
    var return_dict =  {year = year, month = month, day = day, weekday = weekday}
    print(return_dict)
    return return_dict


func return_due_date_dict_from_date_dict(date_dict, days_paid):
    var datetime = add_days(date_dict, days_paid)
    var due_year = datetime["year"]
    var due_month = datetime["month"]
    var due_day = datetime["day"]
    var due_weekday = datetime["weekday"]
    return {due_year = due_year, due_month = due_month, due_day = due_day, due_weekday = due_weekday}


func get_date_dict_from_datetime_dict(datetime_dict):
    return {year = datetime_dict["year"], month = datetime_dict["month"], day = datetime_dict["day"], weekday = datetime_dict["weekday"]}


func num_to_string(num):
    return String.num(num)


func string_to_num(string):
    return string.to_int()


func write_pair_to_dict_in_file(new_key, new_value, file_name_string):
    get_temp_dict_from_file(file_name_string)
    temp_dict[new_key] = new_value
    save_temp_dict_to_file(file_name_string)


func return_current_movein_date_dict():
    return get_date_dict_from_datetime_dict(sub_hours(get_current_datetime_dict(),threshold_hours))


func save_current_move_in_date():
    get_temp_dict_from_file("new_guest")
    var date = get_date_dict_from_datetime_dict(sub_hours(get_current_datetime_dict(),threshold_hours))
    temp_dict.merge(date, true)
    save_temp_dict_to_file("new_guest")


func get_temp_dict_from_file(file_name_string):
    file = FileAccess.open(path_start+file_name_string+".txt", FileAccess.READ)
    temp_dict = JSON.parse_string(file.get_as_text())
    file.close()


func save_temp_dict_to_file(file_name_string):
    file = FileAccess.open(path_start+file_name_string+path_end, FileAccess.WRITE)
    file.store_string(JSON.stringify(temp_dict))
    file.close()


func save_temp_dict_to_new_guest():
    file = FileAccess.open("user://CAPSULES/new_guest.txt", FileAccess.WRITE)
    file.store_string(JSON.stringify(temp_dict))
    file.close()


func change_scene_to(scene):
    get_tree().change_scene_to_file("res://"+scene+".tscn")


func get_current_datetime_dict():
    return Time.get_datetime_dict_from_system()


func add_days(original_day_dict, days_to_add):
    var original_day_unix = Time.get_unix_time_from_datetime_dict(original_day_dict)
    var days_to_add_unix = days_to_add * unix_day
    var return_day_unix = original_day_unix + days_to_add_unix
    var return_day_dict = Time.get_date_dict_from_unix_time(return_day_unix)
    return return_day_dict


func sub_days(original_day_dict, days_to_sub):
    var original_day_unix = Time.get_unix_time_from_datetime_dict(original_day_dict)
    var days_to_sub_unix = days_to_sub * unix_day
    var return_day_unix = original_day_unix - days_to_sub_unix
    var return_day_dict = Time.get_date_dict_from_unix_time(return_day_unix)
    return return_day_dict


func add_hours(original_hour_dict, hours_to_add):
    var original_hour_unix = Time.get_unix_time_from_datetime_dict(original_hour_dict)
    var hours_to_add_unix = hours_to_add * unix_hour
    var return_hour_unix = original_hour_unix + hours_to_add_unix
    var return_hour_dict = Time.get_date_dict_from_unix_time(return_hour_unix)
    return return_hour_dict


func sub_hours(original_hour_dict, hours_to_sub):
    var original_hour_unix = Time.get_unix_time_from_datetime_dict(original_hour_dict)
    var hours_to_sub_unix = hours_to_sub * unix_hour
    var return_hour_unix = original_hour_unix - hours_to_sub_unix
    var return_hour_dict = Time.get_date_dict_from_unix_time(return_hour_unix)
    return return_hour_dict
#endregion


#region ALL -> _READY
# Called when the node enters the scene tree for the first time.
func _ready():
    print("lib.gd ready")
    await get_tree().create_timer(2.0).timeout
    
    get_temp_dict_from_file("dict")
    threshold_hours = temp_dict["threshold_hours"]
    print("threshold_hours = temp_dict[\"threshold_hours\"]")
    print(threshold_hours)
    
    await get_tree().create_timer(1.0).timeout
    loading_done = true
    new_payment_history_key("ПРОГРАММА ЗАПУЩЕНА")
    
    print("\n                                cash debug:")
    cash_make_file()
    cash_load()
    cash_file_max_256()
    print("current pre-close: ", cash_return_current_cash())
    cash_close_shift()
    print("current post-close: ", cash_return_current_cash())
    print("current pre-open: ", cash_return_current_cash())
    cash_open_shift(100)
    print("current post-open: ", cash_return_current_cash())
    print("current before +700: ", cash_return_current_cash())
    cash_add_payment(700,0,0,700,"ТЕСТ ОПЛАТЫ БЛЯДЬ")
    print("current after +700: ", cash_return_current_cash())
    print("curent before -700: ", cash_return_current_cash())
    cash_add_return(700,0,0,700,"ТЕСТ ВОЗВРАТА БЛЯДЬ")
    print("curent after -700: ", cash_return_current_cash())
    print("last payment: ",\
    cash_register_shifts_array[-1]["money_actions"][-1]["money_action"],\
    "\ncommentary: ",\
    cash_register_shifts_array[-1]["money_actions"][-1]["commentary"])
    cash_save()
    print("                                cash debug end\n")
#endregion
    

#region ALL -> _PROCESS
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#region ALL -> _PROCESS -> EXPIRY_PROCESS
    if global_frame_timer["counting"]:
        global_frame_timer["count"] += 1
    else:pass
    if  date_expiry_daysleft() <= days_expired_to_start_crashing:
        var a = randf()
        crash_debug_counter += 1
        if crash_debug_counter % Engine.max_fps == 0:
            @warning_ignore("integer_division")
            print("crash debug counter is " + num_to_string(crash_debug_counter/Engine.max_fps) + " secs")
        else:pass
        if(a<=chance_of_crash):
            print("random number is " + num_to_string(a) + ", chance_of_crash is " + num_to_string(chance_of_crash) + " (approx. " + num_to_string(chance_of_crash_secs) + " secs)")
            get_tree().quit()
    else:pass
#endregion
#endregion
#endregion
