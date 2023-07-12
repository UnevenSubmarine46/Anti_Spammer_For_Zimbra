#Скрипт антиспама ( Проверяет количество писем в очереди от конкретного пользователя. В случае, если лимит превышается, пользователь банится
#После бана пользователя - происходит очистка почтовой очереди от его писем

#Получаем очередь по пользователям на данный момент


postqueue -p |  grep @resanta.ru | awk '{ print $7}' | sort | uniq -c  | sort -r -k1 | grep resanta  > spammers.txt


#Проверяем 5 первых по  количеству писем учеток

while read i;
        do
        mails=`echo $i | cut -d " " -f1`
        name=`echo $i | cut -d " " -f2`

        if [ $mails -gt 1000 ] # Здесь указывается лимит сообщений в очереди
        then
        #echo  "$name Spammer!!!"

        #Меняем статус учетки на закрытый, чтобы пользователь не смог отправлять/получать сообщения
#               zmprov ma $name  zimbraAccountStatus closed #Поменять после теста

#Очищаеем почтовую очередь от данного пользователя----------------------------------------------------------------------------------------

#Получаем id сообщений в очереди  и записываем в временный файл
idlist=`/opt/zimbra/common/sbin/postqueue -p | grep "$name" |cut -d " " -f1 | cut -d "*" -f1` #Поменять после теста

curl -s -X POST https://api.telegram.org/bot5950614981:AAF1qjG_Matt5W_sGAuJpxHrnR3GFW6N8oc/sendMessage -d chat_id=-846339891 -d \text="$(printf "Почтовый ящик: %s\nКоличество писем в очереди: %s\nЛимит превышен, пользователь заблокирован %s" "$name" "$mails" " ")"

#Проходимся циклом и удаляем сообщения из очереди
for a in $idlist

    do
        sudo -u root  /opt/zimbra/common/sbin/postsuper -d $a > /dev/null 2>&1

    done

        else
                echo " $name  Not a spammer" >> /dev/null
                #curl POST https://api.telegram.org/bot5950614981:AAF1qjG_Matt5W_sGAuJpxHrnR3GFW6N8oc/sendMessage -d chat_id=-846339891 -d \text="$(printf "Спамеров нет!!!: %s\nКоличество писем в очереди: %s\n%s" "" "" " ")"

        fi

        done < spammers.txt
        #curl POST https://api.telegram.org/bot5950614981:AAF1qjG_Matt5W_sGAuJpxHrnR3GFW6N8oc/sendMessage -d chat_id=-846339891 -d \text="$(printf "Тест Крона: %s\nКоличество писем в очереди: %s\n%s" "" "" " ")"

        #done < spammers.txt
