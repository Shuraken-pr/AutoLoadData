object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 593
  ClientWidth = 1077
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 1077
    Height = 593
    Align = alClient
    TabOrder = 0
    object grAutoData: TcxGrid
      Left = 503
      Top = 33
      Width = 531
      Height = 539
      TabOrder = 11
      object tvAutoData: TcxGridTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Kind = skSum
            Position = spFooter
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skSum
          end
          item
            Format = '%2.2d'
            Kind = skSum
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.Footer = True
        OptionsView.GroupFooters = gfAlwaysVisible
        object gcAuto: TcxGridColumn
          Caption = #1040#1074#1090#1086
          PropertiesClassName = 'TcxTextEditProperties'
          Styles.GroupSummary = stGroupSummary
          OnCustomDrawFooterCell = gcAutoCustomDrawFooterCell
        end
        object gcParking: TcxGridColumn
          Caption = #1055#1072#1088#1082#1086#1074#1082#1072
          PropertiesClassName = 'TcxTextEditProperties'
          Styles.GroupSummary = stGroupSummary
        end
      end
      object glAutoData: TcxGridLevel
        GridView = tvAutoData
      end
    end
    object mXLSDescription: TcxMemo
      Left = 40
      Top = 75
      Lines.Strings = (
        '')
      Properties.ReadOnly = True
      Properties.ScrollBars = ssVertical
      Properties.WantReturns = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 0
      Height = 154
      Width = 185
    end
    object mPGDescription: TcxMemo
      Left = 260
      Top = 75
      Properties.ReadOnly = True
      Properties.ScrollBars = ssVertical
      Properties.WantReturns = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 3
      Height = 154
      Width = 194
    end
    object beXLSPath: TcxButtonEdit
      Left = 40
      Top = 257
      AutoSize = False
      Properties.Buttons = <
        item
          Default = True
          Glyph.SourceDPI = 96
          Glyph.Data = {
            89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
            610000001D744558745469746C65004578706F72743B586C733B4578706F7274
            546F586C733B4CA099FE000001DD49444154785E8D53BB6E134114BDB36C2022
            54FC004A9D86062571E42C523AA4144097262028E90C45522414AC11B8A78970
            E8D2B988446B05AD6DF111F00D29E23CBCBB3393B36766562BDC30D6F83EF69E
            73CFDD995522F2EF9660E77D2E8B5D5A2C5889B1D597A3DFC34845897B8A9F75
            2863F98F18D6C2225B9637D9C1BBA75BC015812012AB92CEDB27357FEDCC8792
            7E9BB461EE340954690D81B35C134071B4814431BF7857892E8DB0299727D0B9
            66A02B4000FB57426E653D3146D0AC554D02B06A42AC27B04AD1B7AE34F8244B
            561F494A684341A10D0B0CAA3FFEDC91ECCF29891C29DCE01BE73F3E8CA7D815
            601071042A406C84E0F1FB29F159674AA20C7100BF5EDF9333E4CF9043DB1754
            9017DA77B2BE1375736663495C8FB7DBDA97CDAF4B8ECDF8B75978055A3BD0F7
            498AEE97D28775E74F30498EC75D74BF605D95742368AFC05541E6BE6CF4EECB
            ABB53DE691AB151C8F3E81E4B30C3B17C4C4810011A50600B9828B3C6606B82B
            BB203748FE80BA9AA0342CE683D6F236BA2FB1639BB3C2F66809E86769F3C807
            E11E90E0C1622CE9F3132F809DBD6FEA5C36F92B2F9FAD3C04C179B807657E7D
            F5EBCD874162808AFCC5A97CA5C289081722C9679723B879F3538DB0EF612FFC
            C7276DFD47748D263CBA5B445552645BC908B30000000049454E44AE426082}
          Hint = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1079#1072#1075#1088#1091#1079#1082#1080
          Kind = bkGlyph
        end>
      Properties.OnButtonClick = beXLSPathPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      Style.ButtonStyle = bts3D
      TabOrder = 1
      Height = 23
      Width = 185
    end
    object btnXLSLoadData: TcxButton
      Left = 40
      Top = 287
      Width = 185
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1076#1072#1085#1085#1099#1077
      TabOrder = 2
      OnClick = btnXLSLoadDataClick
    end
    object edServer: TcxTextEdit
      Left = 333
      Top = 236
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 4
      Text = 'localhost'
      Width = 121
    end
    object edPort: TcxTextEdit
      Left = 333
      Top = 266
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 5
      Text = '5432'
      Width = 121
    end
    object edNameDB: TcxTextEdit
      Left = 333
      Top = 296
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 6
      Text = 'postgres'
      Width = 121
    end
    object edLogin: TcxTextEdit
      Left = 333
      Top = 326
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 7
      Text = 'postgres'
      Width = 121
    end
    object edPassword: TcxTextEdit
      Left = 333
      Top = 356
      Properties.EchoMode = eemPassword
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 8
      Width = 121
    end
    object mSQL: TcxMemo
      Left = 260
      Top = 407
      Lines.Strings = (
        'select '
        '  a.car,'
        '  a.parking,'
        '  a.date_from,'
        '  a.date_to'
        '  from public.autodata a '
        '  order by a.date_from')
      Properties.ScrollBars = ssVertical
      Properties.WantReturns = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 9
      Height = 119
      Width = 194
    end
    object btnPGLoadData: TcxButton
      Left = 260
      Top = 533
      Width = 194
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1076#1072#1085#1085#1099#1077
      TabOrder = 10
      OnClick = btnPGLoadDataClick
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = -1
    end
    object lgParams: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      AlignHorz = ahLeft
      AlignVert = avClient
      CaptionOptions.Text = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1079#1072#1075#1088#1091#1079#1082#1080
      LayoutDirection = ldHorizontal
      Index = 0
    end
    object lgData: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = #1044#1072#1085#1085#1099#1077
      Index = 1
    end
    object lgExcelParams: TdxLayoutGroup
      Parent = lgParams
      AlignHorz = ahLeft
      AlignVert = avClient
      CaptionOptions.Text = #1047#1072#1075#1088#1091#1079#1082#1072' '#1080#1079' Excel'
      Visible = False
      ItemIndex = 1
      Index = 0
    end
    object lgPostgreParams: TdxLayoutGroup
      Parent = lgParams
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = #1047#1072#1075#1088#1091#1079#1082#1072' '#1080#1079' PostGre'
      Visible = False
      Index = 1
    end
    object ligrAutoData: TdxLayoutItem
      Parent = lgData
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'cxGrid1'
      CaptionOptions.Visible = False
      Control = grAutoData
      ControlOptions.OriginalHeight = 200
      ControlOptions.OriginalWidth = 250
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItem1: TdxLayoutItem
      Parent = lgExcelParams
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1080#1079' Excel'
      CaptionOptions.Layout = clTop
      Control = mXLSDescription
      ControlOptions.OriginalHeight = 154
      ControlOptions.OriginalWidth = 185
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItem2: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1080#1079' PostGre'
      CaptionOptions.Layout = clTop
      Control = mPGDescription
      ControlOptions.OriginalHeight = 154
      ControlOptions.OriginalWidth = 185
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liXLSPath: TdxLayoutItem
      Parent = lgExcelParams
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1060#1072#1081#1083' '#1076#1083#1103' '#1079#1072#1075#1088#1091#1079#1082#1080
      CaptionOptions.Layout = clTop
      Control = beXLSPath
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItem3: TdxLayoutItem
      Parent = lgExcelParams
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      CaptionOptions.Layout = clTop
      Control = btnXLSLoadData
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liServer: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1057#1077#1088#1074#1077#1088
      Control = edServer
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liPort: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1055#1086#1088#1090
      Control = edPort
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liNameDB: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
      Control = edNameDB
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liLogin: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1051#1086#1075#1080#1085
      Control = edLogin
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object liPassword: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1055#1072#1088#1086#1083#1100
      Control = edPassword
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object dxLayoutItem4: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = #1047#1072#1087#1088#1086#1089
      CaptionOptions.Layout = clTop
      Control = mSQL
      ControlOptions.OriginalHeight = 119
      ControlOptions.OriginalWidth = 185
      ControlOptions.ShowBorder = False
      Index = 6
    end
    object dxLayoutItem5: TdxLayoutItem
      Parent = lgPostgreParams
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnPGLoadData
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 7
    end
  end
  object odXLSLoad: TOpenDialog
    Filter = 'Excel Files|*.xls;*.xlsx'
    Left = 688
    Top = 240
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 84
    Top = 12
    PixelsPerInch = 96
    object stGroupSummary: TcxStyle
      AssignedValues = [svColor]
      Color = clAqua
    end
  end
end
