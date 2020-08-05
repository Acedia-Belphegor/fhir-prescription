require "base64"
require './lib/from_qr/qr_fhir_prescription_generator'

filename = File.join(File.dirname(__FILE__), "qr_example.csv")
params = {
    encoding: "Shift_JIS",
    qr_code: Base64.encode64(File.read(filename, encoding: "shift_jis")),
}
generator = QrFhirPrescriptionGenerator.new(params).perform
result = generator.get_resources.to_json
puts result
__END__

shift_jis
SkFISVM1CjEsMSwxMjM0NTY3LDEzLIjjl8OWQJBsjtCSY4KYgpmCmonvgUCD\nSYOLg0qDToOKg2qDYoNOCjIsMTEzLTAwMjEsk4yLnpNzlbaLnovmlnuL7o2e\nglE/glGCVz+CUIJVgUCC2YKwgtmCsINyg4uCWIJYgmUKMywwMy0zOTQ2LTAw\nMDEsMDMtMzk0Ni0wMDAyCjQsMiwwMSyT4InICjUsLCyDZYNYg2eI4450CjEx\nLCyL44ifl6yBQInUjnEst62zsbDZIMrFugoxMiwyCjEzLDE5NjcxMDEyCjIx\nLDEKMjIsMDYyNzA0MDkKMjMsLCwxCjI3LDIxMTM2NzkxLDYyNDczNzMKNTEs\nMjAyMDAzMTkKNjEsNjI1MTYsk4yLnpNzkKKTY5JKi+aCUD+CUYJSP4JTglQ/\nglWCVoJXLDAzLTExMTEtMjIyMgoxMDEsMSwxLCwxNAoxMTEsMSwxLCwxk/oz\nifEgloiQSIzjLDMKMjAxLDEsMSwsNywxMTQ5MDE5RjFaWlosgXmUyoF6g42D\nTINcg3aDjYN0g0aDk4JtgoGP+YJVgk+CjYKHLDMsMSyP+QoyODEsMSwxLDEs\nLJXKle8KMjAxLDEsMiwsMywyMzI5MDIxRjEwMjEsg4CDUoNYg16P+SCCUIJP\ngk+CjYKHLDMsMSyP+QoyODEsMSwyLDEsLJXKle8KMTAxLDIsMSwsMTQKMTEx\nLDIsMSwsMZP6MonxIJKpgUWXW5BIjOMsMgoyMDEsMiwxLCwzLDIxNzEwMTRH\nMTAyMCyDQYNfg4mBW4NngmuP+SCCUIJPgo2ChywyLDEsj/kKMjgxLDIsMSwx\nLDIslbKN0woyODEsMiwxLDIsMyyM45StlWmVz41YlXOJwgoxMDEsMywxLCwx\nNAoxMTEsMywxLCwxk/oxifEgl1uQSIzjLDEKMjAxLDMsMSwsMyw4MTE0MDA0\nRzEwMjcsgmyCcoNSg5ODYIOTj/kgglCCT4KNgocsMSwxLI/5CjEwMSw0LDMs\nLDEKMTExLDQsMSwsMZP6MonxIJNclXQsMAoyMDEsNCwxLCwzLDI2NDk4NDNT\nMTAzOSyCbIJyibeDVoNig3aBdYNeg0ODeoNFgXaCUYJPgoeBaYJUloeBXpHc\ngWosMywxLJHcCjEwMSw1LDUsLDEKMTExLDUsMSwsMZP6M4nxIJaIkEiRTyww\nCjIwMSw1LDEsLDMsMjQ5MjQxM0c0MDQwLINtg3uDioOTglGCT4Jxko2DdIOM\ng2KDToNYg3mDkywxLDEsg0yDYoNnCjEwMSw2LDMsLDEKMTExLDYsMSwsMZP6\nM4nxIJNolXosMAoyMDEsNiwxLCwzLDcxMjE3MDNYMTAxMSyUkpBGg4+DWoOK\ng5MsMjAsMSxnCjIwMSw2LDIsLDcsLINPg4qDgYNUg12Dk5PujXAsMzAsMSxn\n

utf-8
SkFISVM1CjEsMSwxMjM0NTY3LDEzLOWMu+eZguazleS6uuekvuWbo++9mO+9\nme+9muS8muOAgOOCquODq+OCq+OCr+ODquODi+ODg+OCrwoyLDExMy0wMDIx\nLOadseS6rOmDveaWh+S6rOWMuuacrOmnkui+vO+8kuKIku+8ku+8mOKIku+8\nke+8luOAgOOBu+OBkuOBu+OBkuODk+ODq++8me+8me+8pgozLDAzLTM5NDYt\nMDAwMSwwMy0zOTQ2LTAwMDIKNCwyLDAxLOWGheenkQo1LCws44OG44K544OI\n5Yy75birCjExLCzkuZ3kupzmtYHjgIDoirHlrZAs7723772t772z772x772w\n776ZIO++iu++he+9ugoxMiwyCjEzLDE5NjcxMDEyCjIxLDEKMjIsMDYyNzA0\nMDkKMjMsLCwxCjI3LDIxMTM2NzkxLDYyNDczNzMKNTEsMjAyMDAzMTkKNjEs\nNjI1MTYs5p2x5Lqs6YO95LiW55Sw6LC35Yy677yR4oiS77yS77yT4oiS77yU\n77yV4oiS77yW77yX77yYLDAzLTExMTEtMjIyMgoxMDEsMSwxLCwxNAoxMTEs\nMSwxLCwx5pelM+WbniDmr47po5/lvowsMwoyMDEsMSwxLCw3LDExNDkwMTlG\nMVpaWizjgJDoiKzjgJHjg63jgq3jgr3jg5fjg63jg5Xjgqfjg7PvvK7vvYHp\njKDvvJbvvJDvvY3vvYcsMywxLOmMoAoyODEsMSwxLDEsLOWIpeWMhQoyMDEs\nMSwyLCwzLDIzMjkwMjFGMTAyMSzjg6DjgrPjgrnjgr/pjKAg77yR77yQ77yQ\n772N772HLDMsMSzpjKAKMjgxLDEsMiwxLCzliKXljIUKMTAxLDIsMSwsMTQK\nMTExLDIsMSwsMeaXpTLlm54g5pyd44O75aSV6aOf5b6MLDIKMjAxLDIsMSws\nMywyMTcxMDE0RzEwMjAs44Ki44OA44Op44O844OI77ys6YygIO+8ke+8kO+9\nje+9hywyLDEs6YygCjI4MSwyLDEsMSwyLOeyieeglQoyODEsMiwxLDIsMyzl\nvoznmbrlk4HlpInmm7TkuI3lj68KMTAxLDMsMSwsMTQKMTExLDMsMSwsMeaX\npTHlm54g5aSV6aOf5b6MLDEKMjAxLDMsMSwsMyw4MTE0MDA0RzEwMjcs77yt\n77yz44Kz44Oz44OB44Oz6YygIO+8ke+8kO+9je+9hywxLDEs6YygCjEwMSw0\nLDMsLDEKMTExLDQsMSwsMeaXpTLlm54g6LK85LuYLDAKMjAxLDQsMSwsMywy\nNjQ5ODQzUzEwMzks77yt77yz5rip44K344OD44OX44CM44K/44Kk44Ob44Km\n44CN77yS77yQ772H77yI77yV5p6a77yP6KKL77yJLDMsMSzooosKMTAxLDUs\nNSwsMQoxMTEsNSwxLCwx5pelM+WbniDmr47po5/liY0sMAoyMDEsNSwxLCwz\nLDI0OTI0MTNHNDA0MCzjg47jg5zjg6rjg7PvvJLvvJDvvLLms6jjg5Xjg6zj\ng4Pjgq/jgrnjg5rjg7MsMSwxLOOCreODg+ODiAoxMDEsNiwzLCwxCjExMSw2\nLDEsLDHml6Uz5ZueIOWhl+W4gywwCjIwMSw2LDEsLDMsNzEyMTcwM1gxMDEx\nLOeZveiJsuODr+OCu+ODquODsywyMCwxLGcKMjAxLDYsMiwsNyws44Kw44Oq\n44Oh44K144K+44Oz6Luf6IaPLDMwLDEsZw==\n
