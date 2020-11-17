# fhir-prescription

既存標準フォーマットを `電子処方箋 FHIR Document` に変換するAPI

[TestPage](https://fhir-prescription.herokuapp.com/fhir_testers)

## HL7CDA-R2 to FHIR

### request
`POST` /api/hl7/cda_fhir_prescription_generators?format=json

| attributes | description |
| :--- | :--- |
| encoding | `UTF-8` |
| document | Base64にエンコードした `電子処方箋CDA` 形式のXMLデータ |

### example

```
{
    "encoding": "UTF-8",
    "document": "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPENsaW5p\nY2FsRG9jdW1lbnQgeG1sbnM6eHNpPSJodHRwOi8vd3d3LnczLm9yZy8yMDAx\nL1hNTFNjaGVtYS1pbnN0YW5jZSIgeG1sbnM6eHNkPSJodHRwOi8vd3d3Lncz\nLm9yZy8yMDAxL1hNTFNjaGVtYSIgbW9vZENvZGU9IkVWTiIgeG1sbnM9InVy\nbjpobDctb3JnOnYzIj4KICAgIDxyZWFsbUNvZGUgY29kZT0iSlAiLz4KICAg\nIDx0eXBlSWQgcm9vdD0iMi4xNi44NDAuMS4xMTM4ODMuMS4zIiBleHRlbnNp\nb249IlBPQ0RfSEQwMDAwNDAiLz4KICAgIDxpZCByb290PSIxLjIuMzkyLjEw\nMDQ5NS4yMC4zLjExIiBleHRlbnNpb249IjAiLz4KICAgIDxjb2RlIGNvZGU9\nIjAxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEwMDQ5NS4yMC4yLjExIi8+CiAg\nICA8dGl0bGU+5Yem5pa5566LPC90aXRsZT4KICAgIDxlZmZlY3RpdmVUaW1l\nIHZhbHVlPSIyMDE4MTEzMDIzNTk1OSIvPgogICAgPGNvbmZpZGVudGlhbGl0\neUNvZGUgY29kZT0iTiIgY29kZVN5c3RlbT0iMi4xNi44NDAuMS4xMTM4ODMu\nNS4yNSIvPgogICAgPHZlcnNpb25OdW1iZXIgdmFsdWU9IjEiLz4KICAgIDxy\nZWNvcmRUYXJnZXQ+CiAgICAgICAgPHBhdGllbnRSb2xlPgogICAgICAgICAg\nICA8aWQgcm9vdD0iMS4yLjM5Mi4xMDA0OTUuMjAuMy41MS4xMTMxOTk5OTk5\nOSIgZXh0ZW5zaW9uPSI5OTk5MDAxMCIvPgogICAgICAgICAgICA8YWRkcj4K\nICAgICAgICAgICAgICAgIDxzdGF0ZT7mnbHkuqzpg708L3N0YXRlPgogICAg\nICAgICAgICAgICAgPGNvdW50eT5KUE48L2NvdW50eT4KICAgICAgICAgICAg\nICAgIDxjaXR5Pua4r+WMujwvY2l0eT4KICAgICAgICAgICAgICAgIDxwb3N0\nYWxDb2RlPjEwNTAwMDQ8L3Bvc3RhbENvZGU+CiAgICAgICAgICAgICAgICA8\nc3RyZWV0QWRkcmVzc0xpbmU+5paw5qmLMuS4geebrjXnlao15Y+344CA5paw\n5qmLMuS4geebrk1U44OT44OrPC9zdHJlZXRBZGRyZXNzTGluZT4KICAgICAg\nICAgICAgPC9hZGRyPgogICAgICAgICAgICA8dGVsZWNvbSB1c2U9IkhQIiB2\nYWx1ZT0idGVsOjAzMzUwNjgwMTAiLz4KICAgICAgICAgICAgPHRlbGVjb20g\ndXNlPSJIUCIgdmFsdWU9ImZheDowMzM1MDY4MDcwIi8+CiAgICAgICAgICAg\nIDxwYXRpZW50PgogICAgICAgICAgICAgICAgPG5hbWUgdXNlPSJJREUiPgog\nICAgICAgICAgICAgICAgICAgIDxmYW1pbHk+5oKj6ICFPC9mYW1pbHk+CiAg\nICAgICAgICAgICAgICAgICAgPGdpdmVuPuWkqumDjjwvZ2l2ZW4+CiAgICAg\nICAgICAgICAgICA8L25hbWU+CiAgICAgICAgICAgICAgICA8bmFtZSB1c2U9\nIlNZTCI+CiAgICAgICAgICAgICAgICAgICAgPGZhbWlseT7jgqvjg7Pjgrjj\ng6M8L2ZhbWlseT4KICAgICAgICAgICAgICAgICAgICA8Z2l2ZW4+44K/44Ot\n44KmPC9naXZlbj4KICAgICAgICAgICAgICAgIDwvbmFtZT4KICAgICAgICAg\nICAgICAgIDxhZG1pbmlzdHJhdGl2ZUdlbmRlckNvZGUgY29kZT0iTSIgY29k\nZVN5c3RlbT0iMi4xNi44NDAuMS4xMTM4ODMuNS4xIi8+CiAgICAgICAgICAg\nICAgICA8YmlydGhUaW1lIHZhbHVlPSIxOTc5MTEwMSIvPgogICAgICAgICAg\nICA8L3BhdGllbnQ+CiAgICAgICAgPC9wYXRpZW50Um9sZT4KICAgIDwvcmVj\nb3JkVGFyZ2V0PgogICAgPGF1dGhvcj4KICAgICAgICA8dGltZSB4c2k6dHlw\nZT0iSVZMX1RTIj4KICAgICAgICAgICAgPGxvdyB2YWx1ZT0iMjAxNjEwMjgi\nLz4KICAgICAgICA8L3RpbWU+CiAgICAgICAgPGFzc2lnbmVkQXV0aG9yPgog\nICAgICAgICAgICA8aWQgcm9vdD0iMS4yLjM5Mi4xMDA0OTUuMjAuMy40MS4x\nMTMxOTk5OTk5OSIgZXh0ZW5zaW9uPSJEMTAwIi8+CiAgICAgICAgICAgIDxp\nZCByb290PSIxLjIuMzkyLjEwMDQ5NS4yMC4zLjMxIiBleHRlbnNpb249IjEy\nMzQ1Njc4Ii8+CiAgICAgICAgICAgIDxpZCByb290PSIxLjIuMzkyLjEwMDQ5\nNS4yMC4zLjMyLjEzIiBleHRlbnNpb249IjEyMzQtMSIvPgogICAgICAgICAg\nICA8YXNzaWduZWRQZXJzb24+CiAgICAgICAgICAgICAgICA8bmFtZSB1c2U9\nIklERSI+CiAgICAgICAgICAgICAgICAgICAgPGZhbWlseT7ljLvluKs8L2Zh\nbWlseT4KICAgICAgICAgICAgICAgICAgICA8Z2l2ZW4+5LiA6YOOPC9naXZl\nbj4KICAgICAgICAgICAgICAgIDwvbmFtZT4KICAgICAgICAgICAgICAgIDxu\nYW1lIHVzZT0iU1lMIj4KICAgICAgICAgICAgICAgICAgICA8ZmFtaWx5PuOC\npOOCtzwvZmFtaWx5PgogICAgICAgICAgICAgICAgICAgIDxnaXZlbj7jgqTj\ng4Hjg63jgqY8L2dpdmVuPgogICAgICAgICAgICAgICAgPC9uYW1lPgogICAg\nICAgICAgICA8L2Fzc2lnbmVkUGVyc29uPgogICAgICAgICAgICA8cmVwcmVz\nZW50ZWRPcmdhbml6YXRpb24+CiAgICAgICAgICAgICAgICA8aWQgcm9vdD0i\nMS4yLjM5Mi4xMDA0OTUuMjAuMy4yMSIgZXh0ZW5zaW9uPSIxMyIvPgogICAg\nICAgICAgICAgICAgPGlkIHJvb3Q9IjEuMi4zOTIuMTAwNDk1LjIwLjMuMjIi\nIGV4dGVuc2lvbj0iMSIvPgogICAgICAgICAgICAgICAgPGlkIHJvb3Q9IjEu\nMi4zOTIuMTAwNDk1LjIwLjMuMjMiIGV4dGVuc2lvbj0iOTk5OTk5OSIvPgog\nICAgICAgICAgICAgICAgPG5hbWUgdXNlPSJJREUiPuODoeODieODrOODvOOC\nr+ODquODi+ODg+OCrzwvbmFtZT4KICAgICAgICAgICAgICAgIDx0ZWxlY29t\nIHZhbHVlPSJ0ZWw6MDMxMjM0NTY3Ii8+CiAgICAgICAgICAgICAgICA8YWRk\ncj4KICAgICAgICAgICAgICAgICAgICA8c3RhdGU+5p2x5Lqs6YO9PC9zdGF0\nZT4KICAgICAgICAgICAgICAgICAgICA8Y291bnR5PkpQTjwvY291bnR5Pgog\nICAgICAgICAgICAgICAgICAgIDxjaXR5Pua4r+WMujwvY2l0eT4KICAgICAg\nICAgICAgICAgICAgICA8cG9zdGFsQ29kZT4xMDY2MjIyPC9wb3N0YWxDb2Rl\nPgogICAgICAgICAgICAgICAgICAgIDxzdHJlZXRBZGRyZXNzTGluZT7lha3m\nnKzmnKjvvJPiiJLvvJLiiJLvvJEg5L2P5Y+L5LiN5YuV55Sj5YWt5pys5pyo\n44Kw44Op44Oz44OJ44K/44Ov44O877yS77yS77ymPC9zdHJlZXRBZGRyZXNz\nTGluZT4KICAgICAgICAgICAgICAgIDwvYWRkcj4KICAgICAgICAgICAgICAg\nIDxhc09yZ2FuaXphdGlvblBhcnRPZj4KICAgICAgICAgICAgICAgICAgICA8\nY29kZSBjb2RlPSIwMSIgY29kZVN5c3RlbT0iMS4yLjM5Mi4xMDA0OTUuMjAu\nMi41MSIgZGlzcGxheU5hbWU9IuWGheenkSIvPgogICAgICAgICAgICAgICAg\nPC9hc09yZ2FuaXphdGlvblBhcnRPZj4KICAgICAgICAgICAgPC9yZXByZXNl\nbnRlZE9yZ2FuaXphdGlvbj4KICAgICAgICA8L2Fzc2lnbmVkQXV0aG9yPgog\nICAgPC9hdXRob3I+CiAgICA8Y3VzdG9kaWFuPgogICAgICAgIDxhc3NpZ25l\nZEN1c3RvZGlhbj4KICAgICAgICAgICAgPHJlcHJlc2VudGVkQ3VzdG9kaWFu\nT3JnYW5pemF0aW9uIG51bGxGbGF2b3I9Ik5BIi8+CiAgICAgICAgPC9hc3Np\nZ25lZEN1c3RvZGlhbj4KICAgIDwvY3VzdG9kaWFuPgogICAgPGNvbXBvbmVu\ndD4KICAgICAgICA8c3RydWN0dXJlZEJvZHk+CiAgICAgICAgICAgIDxjb21w\nb25lbnQ+CiAgICAgICAgICAgICAgICA8c2VjdGlvbj4KICAgICAgICAgICAg\nICAgICAgICA8Y29kZSBjb2RlPSIwMSIgY29kZVN5c3RlbT0iMS4yLjM5Mi4x\nMDA0OTUuMjAuMi4xMiIvPgogICAgICAgICAgICAgICAgICAgIDx0aXRsZT7l\nh6bmlrnmjIfnpLo8L3RpdGxlPgogICAgICAgICAgICAgICAgICAgIDx0ZXh0\nPgogICAgICAgICAgICAgICAgICAgICAgICA8bGlzdD4KICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDxpdGVtPlJQMTwvaXRlbT4KICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDxpdGVtPuODoOOCs+ODgOOCpOODs+mMoO+8ku+8\nle+8kO+9je+9hzwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAg\nIDxpdGVtPjMg6YygPC9pdGVtPgogICAgICAgICAgICAgICAgICAgICAgICAg\nICAgPGl0ZW0+77yR5pel77yT5Zue5pyd5pi85aSV6aOf5b6MPC9pdGVtPgog\nICAgICAgICAgICAgICAgICAgICAgICAgICAgPGl0ZW0+MyDml6XliIY8L2l0\nZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT5SUDE8L2l0\nZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT7jg5Hjg7Pj\ngrnjg53jg6rjg7PvvLTpjKDvvJHvvJDvvJDjgIDvvJHvvJDvvJDvvY3vvYc8\nL2l0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT42IOmM\noDwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVtPu+8\nkeaXpe+8k+WbnuacneaYvOWklemjn+W+jDwvaXRlbT4KICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDxpdGVtPjMg5pel5YiGPC9pdGVtPgogICAgICAg\nICAgICAgICAgICAgICAgICAgICAgPGl0ZW0+UlAyPC9pdGVtPgogICAgICAg\nICAgICAgICAgICAgICAgICAgICAgPGl0ZW0+44Ki44Os44OU44Ki44OB44Oz\n77yR77yQ77yFPC9pdGVtPgogICAgICAgICAgICAgICAgICAgICAgICAgICAg\nPGl0ZW0+MTAwIO+9je+9hzwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAg\nICAgICAgIDxpdGVtPu+8keaXpe+8kuWbnuacneWklemjn+W+jDwvaXRlbT4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVtPjE0IOaXpeWIhjwv\naXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVtPlJQMjwv\naXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVtPuODleOC\np+ODjuODkOODq+ODk+OCv+ODvOODq+aVo++8ke+8kO+8heOAjOODm+OCqOOC\npOOAjTwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVt\nPjEwMCDvvY3vvYc8L2l0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAg\nICA8aXRlbT7vvJHml6XvvJLlm57mnJ3lpJXpo5/lvow8L2l0ZW0+CiAgICAg\nICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT4xNCDml6XliIY8L2l0ZW0+\nCiAgICAgICAgICAgICAgICAgICAgICAgIDwvbGlzdD4KICAgICAgICAgICAg\nICAgICAgICA8L3RleHQ+CiAgICAgICAgICAgICAgICAgICAgPGVudHJ5Pgog\nICAgICAgICAgICAgICAgICAgICAgICA8c3Vic3RhbmNlQWRtaW5pc3RyYXRp\nb24gY2xhc3NDb2RlPSJTQkFETSIgbW9vZENvZGU9IlJRTyI+CiAgICAgICAg\nICAgICAgICAgICAgICAgICAgICA8aWQgcm9vdD0iMS4yLjM5Mi4xMDA0OTUu\nMjAuMy44MSIgZXh0ZW5zaW9uPSIxIi8+CiAgICAgICAgICAgICAgICAgICAg\nICAgICAgICA8Y29kZSBjb2RlPSIxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEw\nMDQ5NS4yMC4yLjIxIiBkaXNwbGF5TmFtZT0i5YaF5pyNIiAvPgogICAgICAg\nICAgICAgICAgICAgICAgICAgICAgPGVmZmVjdGl2ZVRpbWUgb3BlcmF0b3I9\nIkEiIHhzaTp0eXBlPSJFSVZMX1RTIj4KICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICA8ZXZlbnQgY29kZT0iMTAxMzA0NDQwMDAwMDAwMCIgY29k\nZVN5c3RlbT0iMS4yLjM5Mi4xMDA0OTUuMjAuMi4zMSIgZGlzcGxheU5hbWU9\nIuWGheacjeODu+e1jOWPo+ODu++8keaXpe+8k+WbnuacneaYvOWklemjn+W+\njCIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9lZmZlY3RpdmVU\naW1lPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPGVmZmVjdGl2ZVRp\nbWUgeHNpOnR5cGU9IklWTF9UUyI+CiAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgPHdpZHRoIHZhbHVlPSIzLjAiIHVuaXQ9ImQiLz4KICAgICAg\nICAgICAgICAgICAgICAgICAgICAgIDwvZWZmZWN0aXZlVGltZT4KICAgICAg\nICAgICAgICAgICAgICAgICAgICAgIDxkb3NlUXVhbnRpdHkgdmFsdWU9IjEu\nMCIgdW5pdD0i6YygIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8\nY29uc3VtYWJsZT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8\nbWFudWZhY3R1cmVkUHJvZHVjdD4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgPG1hbnVmYWN0dXJlZExhYmVsZWREcnVnPgogICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPGNvZGUgY29kZT0i\nMTAzODM1NDAxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEwMDQ5NS4yMC4yLjc0\nIiBkaXNwbGF5TmFtZT0i44Og44Kz44OA44Kk44Oz6Yyg77yS77yV77yQ772N\n772HIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwv\nbWFudWZhY3R1cmVkTGFiZWxlZERydWc+CiAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgPC9tYW51ZmFjdHVyZWRQcm9kdWN0PgogICAgICAgICAg\nICAgICAgICAgICAgICAgICAgPC9jb25zdW1hYmxlPgogICAgICAgICAgICAg\nICAgICAgICAgICAgICAgPGVudHJ5UmVsYXRpb25zaGlwIHR5cGVDb2RlPSJS\nRUZSIiBpbnZlcnNpb25JbmQ9ImZhbHNlIj4KICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8c3VwcGx5IGNsYXNzQ29kZT0iU1BMWSIgbW9vZENv\nZGU9IlJRTyI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nIDx0ZXh0PjwvdGV4dD4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgPHF1YW50aXR5IHZhbHVlPSI5LjAiIHVuaXQ9IumMoCIvPgogICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvc3VwcGx5PgogICAgICAg\nICAgICAgICAgICAgICAgICAgICAgPC9lbnRyeVJlbGF0aW9uc2hpcD4KICAg\nICAgICAgICAgICAgICAgICAgICAgICAgIDxkb3NlQ2hlY2tRdWFudGl0eT4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8bnVtZXJhdG9yIHZh\nbHVlPSIzLjAiIHVuaXQ9IumMoCI+CiAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgIDx0cmFuc2xhdGlvbiBjb2RlPSIxIiBjb2RlU3lzdGVt\nPSIxLjIuMzkyLjEwMDQ5NS4yMC4yLjIyIiBkaXNwbGF5TmFtZT0i6KO95Ymk\n6YePIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9udW1l\ncmF0b3I+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPGRlbm9t\naW5hdG9yIHZhbHVlPSIxIiB1bml0PSJkIi8+CiAgICAgICAgICAgICAgICAg\nICAgICAgICAgICA8L2Rvc2VDaGVja1F1YW50aXR5PgogICAgICAgICAgICAg\nICAgICAgICAgICA8L3N1YnN0YW5jZUFkbWluaXN0cmF0aW9uPgogICAgICAg\nICAgICAgICAgICAgIDwvZW50cnk+CiAgICAgICAgICAgICAgICAgICAgPGVu\ndHJ5PgogICAgICAgICAgICAgICAgICAgICAgICA8c3Vic3RhbmNlQWRtaW5p\nc3RyYXRpb24gY2xhc3NDb2RlPSJTQkFETSIgbW9vZENvZGU9IlJRTyI+CiAg\nICAgICAgICAgICAgICAgICAgICAgICAgICA8aWQgcm9vdD0iMS4yLjM5Mi4x\nMDA0OTUuMjAuMy44MSIgZXh0ZW5zaW9uPSIxIi8+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8Y29kZSBjb2RlPSIxIiBjb2RlU3lzdGVtPSIxLjIu\nMzkyLjEwMDQ5NS4yMC4yLjIxIiBkaXNwbGF5TmFtZT0i5YaF5pyNIiAvPgog\nICAgICAgICAgICAgICAgICAgICAgICAgICAgPGVmZmVjdGl2ZVRpbWUgb3Bl\ncmF0b3I9IkEiIHhzaTp0eXBlPSJFSVZMX1RTIj4KICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICA8ZXZlbnQgY29kZT0iMTAxMzA0NDQwMDAwMDAw\nMCIgY29kZVN5c3RlbT0iMS4yLjM5Mi4xMDA0OTUuMjAuMi4zMSIgZGlzcGxh\neU5hbWU9IuWGheacjeODu+e1jOWPo+ODu++8keaXpe+8k+WbnuacneaYvOWk\nlemjn+W+jCIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9lZmZl\nY3RpdmVUaW1lPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPGVmZmVj\ndGl2ZVRpbWUgeHNpOnR5cGU9IklWTF9UUyI+CiAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgPHdpZHRoIHZhbHVlPSIzLjAiIHVuaXQ9ImQiLz4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvZWZmZWN0aXZlVGltZT4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxkb3NlUXVhbnRpdHkgdmFs\ndWU9IjIuMCIgdW5pdD0i6YygIi8+CiAgICAgICAgICAgICAgICAgICAgICAg\nICAgICA8Y29uc3VtYWJsZT4KICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICA8bWFudWZhY3R1cmVkUHJvZHVjdD4KICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgPG1hbnVmYWN0dXJlZExhYmVsZWREcnVnPgog\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPGNvZGUg\nY29kZT0iMTEwNjI2OTAxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEwMDQ5NS4y\nMC4yLjc0IiBkaXNwbGF5TmFtZT0i44OR44Oz44K544Od44Oq44Oz77y06Yyg\n77yR77yQ77yQIO+8ke+8kO+8kO+9je+9hyIvPgogICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICA8L21hbnVmYWN0dXJlZExhYmVsZWREcnVn\nPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvbWFudWZhY3R1\ncmVkUHJvZHVjdD4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvY29u\nc3VtYWJsZT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxlbnRyeVJl\nbGF0aW9uc2hpcCB0eXBlQ29kZT0iUkVGUiIgaW52ZXJzaW9uSW5kPSJmYWxz\nZSI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHN1cHBseSBj\nbGFzc0NvZGU9IlNQTFkiIG1vb2RDb2RlPSJSUU8iPgogICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICA8dGV4dD48L3RleHQ+CiAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxxdWFudGl0eSB2YWx1ZT0i\nMTguMCIgdW5pdD0i6YygIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgPC9zdXBwbHk+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8\nL2VudHJ5UmVsYXRpb25zaGlwPgogICAgICAgICAgICAgICAgICAgICAgICAg\nICAgPGRvc2VDaGVja1F1YW50aXR5PgogICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgIDxudW1lcmF0b3IgdmFsdWU9IjYuMCIgdW5pdD0i6YygIj4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRyYW5zbGF0\naW9uIGNvZGU9IjEiIGNvZGVTeXN0ZW09IjEuMi4zOTIuMTAwNDk1LjIwLjIu\nMjIiIGRpc3BsYXlOYW1lPSLoo73liaTph48iLz4KICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICA8L251bWVyYXRvcj4KICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICA8ZGVub21pbmF0b3IgdmFsdWU9IjEiIHVuaXQ9\nImQiLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvZG9zZUNoZWNr\nUXVhbnRpdHk+CiAgICAgICAgICAgICAgICAgICAgICAgIDwvc3Vic3RhbmNl\nQWRtaW5pc3RyYXRpb24+CiAgICAgICAgICAgICAgICAgICAgPC9lbnRyeT4K\nICAgICAgICAgICAgICAgICAgICA8ZW50cnk+CiAgICAgICAgICAgICAgICAg\nICAgICAgIDxzdWJzdGFuY2VBZG1pbmlzdHJhdGlvbiBjbGFzc0NvZGU9IlNC\nQURNIiBtb29kQ29kZT0iUlFPIj4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgIDxpZCByb290PSIxLjIuMzkyLjEwMDQ5NS4yMC4zLjgxIiBleHRlbnNp\nb249IjIiLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxjb2RlIGNv\nZGU9IjEiIGNvZGVTeXN0ZW09IjEuMi4zOTIuMTAwNDk1LjIwLjIuMjEiIGRp\nc3BsYXlOYW1lPSLlhoXmnI0iIC8+CiAgICAgICAgICAgICAgICAgICAgICAg\nICAgICA8ZWZmZWN0aXZlVGltZSBvcGVyYXRvcj0iQSIgeHNpOnR5cGU9IkVJ\nVkxfVFMiPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxldmVu\ndCBjb2RlPSIxMDEyMDQwNDAwMDAwMDAwIiBjb2RlU3lzdGVtPSIxLjIuMzky\nLjEwMDQ5NS4yMC4yLjMxIiBkaXNwbGF5TmFtZT0i5YaF5pyN44O757WM5Y+j\n44O777yR5pel77yS5Zue5pyd5aSV6aOf5b6MIi8+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8L2VmZmVjdGl2ZVRpbWU+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8ZWZmZWN0aXZlVGltZSB4c2k6dHlwZT0iSVZMX1RT\nIj4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8d2lkdGggdmFs\ndWU9IjE0LjAiIHVuaXQ9ImQiLz4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgIDwvZWZmZWN0aXZlVGltZT4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgIDxkb3NlUXVhbnRpdHkgdmFsdWU9IjUwLjAiIHVuaXQ9Iu+9je+9hyIv\nPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPGNvbnN1bWFibGU+CiAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPG1hbnVmYWN0dXJlZFBy\nb2R1Y3Q+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxt\nYW51ZmFjdHVyZWRMYWJlbGVkRHJ1Zz4KICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgIDxjb2RlIGNvZGU9IjEwMDYwNzAwMiIgY29k\nZVN5c3RlbT0iMS4yLjM5Mi4xMDA0OTUuMjAuMi43NCIgZGlzcGxheU5hbWU9\nIuOCouODrOODk+OCouODgeODs+aVo++8ke+8kO+8hSIvPgogICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICA8L21hbnVmYWN0dXJlZExhYmVs\nZWREcnVnPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvbWFu\ndWZhY3R1cmVkUHJvZHVjdD4KICAgICAgICAgICAgICAgICAgICAgICAgICAg\nIDwvY29uc3VtYWJsZT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxl\nbnRyeVJlbGF0aW9uc2hpcCB0eXBlQ29kZT0iUkVGUiIgaW52ZXJzaW9uSW5k\nPSJmYWxzZSI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHN1\ncHBseSBjbGFzc0NvZGU9IlNQTFkiIG1vb2RDb2RlPSJSUU8iPgogICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dGV4dD48L3RleHQ+CiAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxxdWFudGl0eSB2\nYWx1ZT0iMS40IiB1bml0PSLvvYciLz4KICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICA8L3N1cHBseT4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgIDwvZW50cnlSZWxhdGlvbnNoaXA+CiAgICAgICAgICAgICAgICAgICAg\nICAgICAgICA8ZG9zZUNoZWNrUXVhbnRpdHk+CiAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgPG51bWVyYXRvciB2YWx1ZT0iMTAwLjAiIHVuaXQ9\nIu+9je+9hyI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nIDx0cmFuc2xhdGlvbiBjb2RlPSIxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEw\nMDQ5NS4yMC4yLjIyIiBkaXNwbGF5TmFtZT0i6KO95Ymk6YePIi8+CiAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9udW1lcmF0b3I+CiAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgPGRlbm9taW5hdG9yIHZhbHVl\nPSIxIiB1bml0PSJkIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8\nL2Rvc2VDaGVja1F1YW50aXR5PgogICAgICAgICAgICAgICAgICAgICAgICA8\nL3N1YnN0YW5jZUFkbWluaXN0cmF0aW9uPgogICAgICAgICAgICAgICAgICAg\nIDwvZW50cnk+CiAgICAgICAgICAgICAgICAgICAgPGVudHJ5PgogICAgICAg\nICAgICAgICAgICAgICAgICA8c3Vic3RhbmNlQWRtaW5pc3RyYXRpb24gY2xh\nc3NDb2RlPSJTQkFETSIgbW9vZENvZGU9IlJRTyI+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8aWQgcm9vdD0iMS4yLjM5Mi4xMDA0OTUuMjAuMy44\nMSIgZXh0ZW5zaW9uPSIyIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAg\nICA8Y29kZSBjb2RlPSIxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEwMDQ5NS4y\nMC4yLjIxIiBkaXNwbGF5TmFtZT0i5YaF5pyNIiAvPgogICAgICAgICAgICAg\nICAgICAgICAgICAgICAgPGVmZmVjdGl2ZVRpbWUgb3BlcmF0b3I9IkEiIHhz\naTp0eXBlPSJFSVZMX1RTIj4KICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICA8ZXZlbnQgY29kZT0iMTAxMjA0MDQwMDAwMDAwMCIgY29kZVN5c3Rl\nbT0iMS4yLjM5Mi4xMDA0OTUuMjAuMi4zMSIgZGlzcGxheU5hbWU9IuWGheac\njeODu+e1jOWPo+ODu++8keaXpe+8kuWbnuacneWklemjn+W+jCIvPgogICAg\nICAgICAgICAgICAgICAgICAgICAgICAgPC9lZmZlY3RpdmVUaW1lPgogICAg\nICAgICAgICAgICAgICAgICAgICAgICAgPGVmZmVjdGl2ZVRpbWUgeHNpOnR5\ncGU9IklWTF9UUyI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nPHdpZHRoIHZhbHVlPSIxNC4wIiB1bml0PSJkIi8+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8L2VmZmVjdGl2ZVRpbWU+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8ZG9zZVF1YW50aXR5IHZhbHVlPSI1MC4wIiB1bml0\nPSLvvY3vvYciLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxjb25z\ndW1hYmxlPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxtYW51\nZmFjdHVyZWRQcm9kdWN0PgogICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICA8bWFudWZhY3R1cmVkTGFiZWxlZERydWc+CiAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8Y29kZSBjb2RlPSIxMDA1\nNjUzMTUiIGNvZGVTeXN0ZW09IjEuMi4zOTIuMTAwNDk1LjIwLjIuNzQiIGRp\nc3BsYXlOYW1lPSLjg5Xjgqfjg47jg5Djg6vjg5Pjgr/jg7zjg6vmlaPvvJHv\nvJDvvIXjgIzjg5vjgqjjgqTjgI0iLz4KICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgPC9tYW51ZmFjdHVyZWRMYWJlbGVkRHJ1Zz4KICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L21hbnVmYWN0dXJlZFBy\nb2R1Y3Q+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L2NvbnN1bWFi\nbGU+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8ZW50cnlSZWxhdGlv\nbnNoaXAgdHlwZUNvZGU9IlJFRlIiIGludmVyc2lvbkluZD0iZmFsc2UiPgog\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxzdXBwbHkgY2xhc3ND\nb2RlPSJTUExZIiBtb29kQ29kZT0iUlFPIj4KICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgPHRleHQ+PC90ZXh0PgogICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICA8cXVhbnRpdHkgdmFsdWU9IjEuNCIg\ndW5pdD0i772HIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nPC9zdXBwbHk+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L2VudHJ5\nUmVsYXRpb25zaGlwPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPGRv\nc2VDaGVja1F1YW50aXR5PgogICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgIDxudW1lcmF0b3IgdmFsdWU9IjEwMC4wIiB1bml0PSLvvY3vvYciPgog\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dHJhbnNsYXRp\nb24gY29kZT0iMSIgY29kZVN5c3RlbT0iMS4yLjM5Mi4xMDA0OTUuMjAuMi4y\nMiIgZGlzcGxheU5hbWU9IuijveWJpOmHjyIvPgogICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDwvbnVtZXJhdG9yPgogICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDxkZW5vbWluYXRvciB2YWx1ZT0iMSIgdW5pdD0i\nZCIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9kb3NlQ2hlY2tR\ndWFudGl0eT4KICAgICAgICAgICAgICAgICAgICAgICAgPC9zdWJzdGFuY2VB\nZG1pbmlzdHJhdGlvbj4KICAgICAgICAgICAgICAgICAgICA8L2VudHJ5PiAg\nICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICA8L3NlY3Rpb24+\nCiAgICAgICAgICAgIDwvY29tcG9uZW50PgogICAgICAgICAgICA8Y29tcG9u\nZW50PgogICAgICAgICAgICAgICAgPHNlY3Rpb24+CiAgICAgICAgICAgICAg\nICAgICAgPGNvZGUgY29kZT0iMTEiIGNvZGVTeXN0ZW09IjEuMi4zOTIuMTAw\nNDk1LjIwLjIuMTIiLz4KICAgICAgICAgICAgICAgICAgICA8dGl0bGU+5L+d\n6Zm644O75YWs6LK75oOF5aCxPC90aXRsZT4KICAgICAgICAgICAgICAgICAg\nICA8dGV4dD4KICAgICAgICAgICAgICAgICAgICAgICAgPGxpc3Q+CiAgICAg\nICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT4wNjA1MDExNjwvaXRlbT4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVtPu+8me+8ku+8kO+8\nlO+8lTwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxpdGVt\nPu+8ke+8kDwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxp\ndGVtPuacrOS6ujwvaXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgICAg\nIDxpdGVtPjE1MTM4MDkyPC9pdGVtPgogICAgICAgICAgICAgICAgICAgICAg\nICAgICAgPGl0ZW0+OTYwMzI4MzwvaXRlbT4KICAgICAgICAgICAgICAgICAg\nICAgICAgPC9saXN0PgogICAgICAgICAgICAgICAgICAgIDwvdGV4dD4KICAg\nICAgICAgICAgICAgICAgICA8ZW50cnk+CiAgICAgICAgICAgICAgICAgICAg\nICAgIDxhY3QgY2xhc3NDb2RlPSJBQ1QiIG1vb2RDb2RlPSJFVk4iPgogICAg\nICAgICAgICAgICAgICAgICAgICAgICAgPGNvZGUgY29kZVN5c3RlbT0iMS4y\nLjM5Mi4xMDA0OTUuMjAuMi42NCIvPgogICAgICAgICAgICAgICAgICAgICAg\nICAgICAgPGVudHJ5UmVsYXRpb25zaGlwIHR5cGVDb2RlPSJDT01QIj4KICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8YWN0IGNsYXNzQ29kZT0i\nQUNUIiBtb29kQ29kZT0iRVZOIj4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgPGNvZGUgY29kZT0iMSIgY29kZVN5c3RlbT0iMS4yLjM5\nMi4xMDA0OTUuMjAuMi42MSIgZGlzcGxheU5hbWU9IuWMu+S/nSIvPgogICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8cGVyZm9ybWVyPgog\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPGFzc2ln\nbmVkRW50aXR5PgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgIDxpZCByb290PSIxLjIuMzkyLjEwMDQ5NS4yMC4zLjYxIiBl\neHRlbnNpb249IjA2MDUwMTE2Ii8+CiAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICA8L2Fzc2lnbmVkRW50aXR5PgogICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICA8L3BlcmZvcm1lcj4KICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHBhcnRpY2lwYW50IHR5\ncGVDb2RlPSJDT1YiPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgPHBhcnRpY2lwYW50Um9sZT4KICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICA8aWQgcm9vdD0iMS4yLjM5Mi4x\nMDA0OTUuMjAuMy42MiIgZXh0ZW5zaW9uPSLvvJnvvJLvvJDvvJTvvJUiLz4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8\naWQgcm9vdD0iMS4yLjM5Mi4xMDA0OTUuMjAuMy42MyIgZXh0ZW5zaW9uPSLv\nvJHvvJAiLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICA8Y29kZSBjb2RlPSIxIiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEw\nMDQ5NS4yMC4yLjYyIiBkaXNwbGF5TmFtZT0i6KKr5L+d6Zm66ICFIi8+CiAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3BhcnRp\nY2lwYW50Um9sZT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgPC9wYXJ0aWNpcGFudD4KICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgPGVudHJ5UmVsYXRpb25zaGlwIHR5cGVDb2RlPSJSRUZSIj4K\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxvYnNl\ncnZhdGlvbiBjbGFzc0NvZGU9Ik9CUyIgbW9vZENvZGU9IkRFRiI+CiAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPGNvZGUg\nY29kZT0iMiIgY29kZVN5c3RlbT0iMS4yLjM5Mi4xMDA0OTUuMjAuMi42MyIg\nZGlzcGxheU5hbWU9IumrmOm9ouiAhe+8l+WJsiIvPgogICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9vYnNlcnZhdGlvbj4KICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9lbnRyeVJlbGF0\naW9uc2hpcD4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L2Fj\ndD4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvZW50cnlSZWxhdGlv\nbnNoaXA+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8ZW50cnlSZWxh\ndGlvbnNoaXAgdHlwZUNvZGU9IkNPTVAiPgogICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgIDxhY3QgY2xhc3NDb2RlPSJBQ1QiIG1vb2RDb2RlPSJF\nVk4iPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8Y29k\nZSBjb2RlPSI4IiBjb2RlU3lzdGVtPSIxLjIuMzkyLjEwMDQ5NS4yMC4yLjYx\nIiBkaXNwbGF5TmFtZT0i5YWs6LK7Ii8+CiAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDxwZXJmb3JtZXI+CiAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICA8YXNzaWduZWRFbnRpdHk+CiAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPGlkIHJv\nb3Q9IjEuMi4zOTIuMTAwNDk1LjIwLjMuNzEiIGV4dGVuc2lvbj0iMTUxMzgw\nOTIiLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nIDwvYXNzaWduZWRFbnRpdHk+CiAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgIDwvcGVyZm9ybWVyPgogICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8cGFydGljaXBhbnQgdHlwZUNvZGU9IkNPViI+CiAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8cGFydGlj\naXBhbnRSb2xlPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgIDxpZCByb290PSIxLjIuMzkyLjEwMDQ5NS4yMC4zLjcyIiBl\neHRlbnNpb249Ijk2MDMyODMiLz4KICAgICAgICAgICAgICAgICAgICAgICAg\nICAgICAgICAgICAgICAgIDwvcGFydGljaXBhbnRSb2xlPgogICAgICAgICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICA8L3BhcnRpY2lwYW50PgogICAg\nICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvYWN0PgogICAgICAgICAg\nICAgICAgICAgICAgICAgICAgPC9lbnRyeVJlbGF0aW9uc2hpcD4KICAgICAg\nICAgICAgICAgICAgICAgICAgPC9hY3Q+CiAgICAgICAgICAgICAgICAgICAg\nPC9lbnRyeT4KICAgICAgICAgICAgICAgIDwvc2VjdGlvbj4KICAgICAgICAg\nICAgPC9jb21wb25lbnQ+CiAgICAgICAgICAgIDxjb21wb25lbnQ+CiAgICAg\nICAgICAgICAgICA8c2VjdGlvbj4KICAgICAgICAgICAgICAgICAgICA8Y29k\nZSBjb2RlPSIxMDEiIGNvZGVTeXN0ZW09IjEuMi4zOTIuMTAwNDk1LjIwLjIu\nMTIiLz4KICAgICAgICAgICAgICAgICAgICA8dGl0bGU+5Yem5pa5566L5YKZ\n6ICD5oOF5aCxPC90aXRsZT4KICAgICAgICAgICAgICAgICAgICA8dGV4dD4K\nICAgICAgICAgICAgICAgICAgICAgICAgPGxpc3Q+CiAgICAgICAgICAgICAg\nICAgICAgICAgICAgICA8aXRlbT7oqr/liaTkuIrjga7nlZnmhI/kuovpoIU8\nL2l0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT7purvo\nlqzlh6bmlrnmmYLjga7mgqPogIXkvY/miYDjg7vmlr3nlKjogIXlhY3oqLHn\nlarlj7c8L2l0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRl\nbT7pmZDluqbph4/jgpLotoXjgYjjgZ/mipXkuI7jgpLooYzjgYbnkIbnlLE8\nL2l0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT7vvJbm\nrbPjg7vpq5jkuIDjg7vpq5jvvJc8L2l0ZW0+CiAgICAgICAgICAgICAgICAg\nICAgICAgICAgICA8aXRlbT7lvoznmbrljLvolqzlk4HjgpLlh6bmlrnjgZfj\ngZ/pmpvjgavjgIHlpInmm7TkuI3lj6/jgajjgZfjgZ/nkIbnlLE8L2l0ZW0+\nCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT7mub/luIPolqzj\nga7lpJrph4/mipXkuI7jgpLliKTmlq3jgZfjgZ/otqPml6g8L2l0ZW0+CiAg\nICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT7lnLDln5/ljIXmi6zo\nqLrnmYLliqDnrpfnrYnjgpLnrpflrprjgZfjgabjgYTjgovml6g8L2l0ZW0+\nCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aXRlbT7mrovolqznorro\nqo3mmYLjga7mjIfnpLo8L2l0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAg\nIDwvbGlzdD4KICAgICAgICAgICAgICAgICAgICA8L3RleHQ+CiAgICAgICAg\nICAgICAgICA8L3NlY3Rpb24+CiAgICAgICAgICAgIDwvY29tcG9uZW50Pgog\nICAgICAgICAgICA8Y29tcG9uZW50PgogICAgICAgICAgICAgICAgPHNlY3Rp\nb24+CiAgICAgICAgICAgICAgICAgICAgPGNvZGUgY29kZT0iMjAxIiBjb2Rl\nU3lzdGVtPSIxLjIuMzkyLjEwMDQ5NS4yMC4yLjEyIi8+CiAgICAgICAgICAg\nICAgICAgICAgPHRpdGxlPuWHpuaWueeui+ijnOi2s+aDheWgsTwvdGl0bGU+\nCiAgICAgICAgICAgICAgICAgICAgPHRleHQ+CiAgICAgICAgICAgICAgICAg\nICAgICAgIDxsaXN0PgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPGl0\nZW0+6KOc6Laz5oOF5aCx44KS6aCF55uu44GU44Go44Gr566H5p2h5pu444GN\nPC9pdGVtPgogICAgICAgICAgICAgICAgICAgICAgICA8L2xpc3Q+CiAgICAg\nICAgICAgICAgICAgICAgPC90ZXh0PgogICAgICAgICAgICAgICAgPC9zZWN0\naW9uPgogICAgICAgICAgICA8L2NvbXBvbmVudD4KICAgICAgICA8L3N0cnVj\ndHVyZWRCb2R5PgogICAgPC9jb21wb25lbnQ+CjwvQ2xpbmljYWxEb2N1bWVu\ndD4=\n"
}
```

<details><summary>CDA(原文)</summary>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ClinicalDocument xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" moodCode="EVN" xmlns="urn:hl7-org:v3">
    <realmCode code="JP"/>
    <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
    <id root="1.2.392.100495.20.3.11" extension="0"/>
    <code code="01" codeSystem="1.2.392.100495.20.2.11"/>
    <title>処方箋</title>
    <effectiveTime value="20181130235959"/>
    <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
    <versionNumber value="1"/>
    <recordTarget>
        <patientRole>
            <id root="1.2.392.100495.20.3.51.11319999999" extension="99990010"/>
            <addr>
                <state>東京都</state>
                <county>JPN</county>
                <city>港区</city>
                <postalCode>1050004</postalCode>
                <streetAddressLine>新橋2丁目5番5号　新橋2丁目MTビル</streetAddressLine>
            </addr>
            <telecom use="HP" value="tel:0335068010"/>
            <telecom use="HP" value="fax:0335068070"/>
            <patient>
                <name use="IDE">
                    <family>患者</family>
                    <given>太郎</given>
                </name>
                <name use="SYL">
                    <family>カンジャ</family>
                    <given>タロウ</given>
                </name>
                <administrativeGenderCode code="M" codeSystem="2.16.840.1.113883.5.1"/>
                <birthTime value="19791101"/>
            </patient>
        </patientRole>
    </recordTarget>
    <author>
        <time xsi:type="IVL_TS">
            <low value="20161028"/>
        </time>
        <assignedAuthor>
            <id root="1.2.392.100495.20.3.41.11319999999" extension="D100"/>
            <id root="1.2.392.100495.20.3.31" extension="12345678"/>
            <id root="1.2.392.100495.20.3.32.13" extension="1234-1"/>
            <assignedPerson>
                <name use="IDE">
                    <family>医師</family>
                    <given>一郎</given>
                </name>
                <name use="SYL">
                    <family>イシ</family>
                    <given>イチロウ</given>
                </name>
            </assignedPerson>
            <representedOrganization>
                <id root="1.2.392.100495.20.3.21" extension="13"/>
                <id root="1.2.392.100495.20.3.22" extension="1"/>
                <id root="1.2.392.100495.20.3.23" extension="9999999"/>
                <name use="IDE">メドレークリニック</name>
                <telecom value="tel:031234567"/>
                <addr>
                    <state>東京都</state>
                    <county>JPN</county>
                    <city>港区</city>
                    <postalCode>1066222</postalCode>
                    <streetAddressLine>六本木３−２−１ 住友不動産六本木グランドタワー２２Ｆ</streetAddressLine>
                </addr>
                <asOrganizationPartOf>
                    <code code="01" codeSystem="1.2.392.100495.20.2.51" displayName="内科"/>
                </asOrganizationPartOf>
            </representedOrganization>
        </assignedAuthor>
    </author>
    <custodian>
        <assignedCustodian>
            <representedCustodianOrganization nullFlavor="NA"/>
        </assignedCustodian>
    </custodian>
    <component>
        <structuredBody>
            <component>
                <section>
                    <code code="01" codeSystem="1.2.392.100495.20.2.12"/>
                    <title>処方指示</title>
                    <text>
                        <list>
                            <item>RP1</item>
                            <item>ムコダイン錠２５０ｍｇ</item>
                            <item>3 錠</item>
                            <item>１日３回朝昼夕食後</item>
                            <item>3 日分</item>
                            <item>RP1</item>
                            <item>パンスポリンＴ錠１００　１００ｍｇ</item>
                            <item>6 錠</item>
                            <item>１日３回朝昼夕食後</item>
                            <item>3 日分</item>
                            <item>RP2</item>
                            <item>アレピアチン１０％</item>
                            <item>100 ｍｇ</item>
                            <item>１日２回朝夕食後</item>
                            <item>14 日分</item>
                            <item>RP2</item>
                            <item>フェノバルビタール散１０％「ホエイ」</item>
                            <item>100 ｍｇ</item>
                            <item>１日２回朝夕食後</item>
                            <item>14 日分</item>
                        </list>
                    </text>
                    <entry>
                        <substanceAdministration classCode="SBADM" moodCode="RQO">
                            <id root="1.2.392.100495.20.3.81" extension="1"/>
                            <code code="1" codeSystem="1.2.392.100495.20.2.21" displayName="内服" />
                            <effectiveTime operator="A" xsi:type="EIVL_TS">
                                <event code="1013044400000000" codeSystem="1.2.392.100495.20.2.31" displayName="内服・経口・１日３回朝昼夕食後"/>
                            </effectiveTime>
                            <effectiveTime xsi:type="IVL_TS">
                                <width value="3.0" unit="d"/>
                            </effectiveTime>
                            <doseQuantity value="1.0" unit="錠"/>
                            <consumable>
                                <manufacturedProduct>
                                    <manufacturedLabeledDrug>
                                        <code code="103835401" codeSystem="1.2.392.100495.20.2.74" displayName="ムコダイン錠２５０ｍｇ"/>
                                    </manufacturedLabeledDrug>
                                </manufacturedProduct>
                            </consumable>
                            <entryRelationship typeCode="REFR" inversionInd="false">
                                <supply classCode="SPLY" moodCode="RQO">
                                    <text></text>
                                    <quantity value="9.0" unit="錠"/>
                                </supply>
                            </entryRelationship>
                            <doseCheckQuantity>
                                <numerator value="3.0" unit="錠">
                                    <translation code="1" codeSystem="1.2.392.100495.20.2.22" displayName="製剤量"/>
                                </numerator>
                                <denominator value="1" unit="d"/>
                            </doseCheckQuantity>
                        </substanceAdministration>
                    </entry>
                    <entry>
                        <substanceAdministration classCode="SBADM" moodCode="RQO">
                            <id root="1.2.392.100495.20.3.81" extension="1"/>
                            <code code="1" codeSystem="1.2.392.100495.20.2.21" displayName="内服" />
                            <effectiveTime operator="A" xsi:type="EIVL_TS">
                                <event code="1013044400000000" codeSystem="1.2.392.100495.20.2.31" displayName="内服・経口・１日３回朝昼夕食後"/>
                            </effectiveTime>
                            <effectiveTime xsi:type="IVL_TS">
                                <width value="3.0" unit="d"/>
                            </effectiveTime>
                            <doseQuantity value="2.0" unit="錠"/>
                            <consumable>
                                <manufacturedProduct>
                                    <manufacturedLabeledDrug>
                                        <code code="110626901" codeSystem="1.2.392.100495.20.2.74" displayName="パンスポリンＴ錠１００ １００ｍｇ"/>
                                    </manufacturedLabeledDrug>
                                </manufacturedProduct>
                            </consumable>
                            <entryRelationship typeCode="REFR" inversionInd="false">
                                <supply classCode="SPLY" moodCode="RQO">
                                    <text></text>
                                    <quantity value="18.0" unit="錠"/>
                                </supply>
                            </entryRelationship>
                            <doseCheckQuantity>
                                <numerator value="6.0" unit="錠">
                                    <translation code="1" codeSystem="1.2.392.100495.20.2.22" displayName="製剤量"/>
                                </numerator>
                                <denominator value="1" unit="d"/>
                            </doseCheckQuantity>
                        </substanceAdministration>
                    </entry>
                    <entry>
                        <substanceAdministration classCode="SBADM" moodCode="RQO">
                            <id root="1.2.392.100495.20.3.81" extension="2"/>
                            <code code="1" codeSystem="1.2.392.100495.20.2.21" displayName="内服" />
                            <effectiveTime operator="A" xsi:type="EIVL_TS">
                                <event code="1012040400000000" codeSystem="1.2.392.100495.20.2.31" displayName="内服・経口・１日２回朝夕食後"/>
                            </effectiveTime>
                            <effectiveTime xsi:type="IVL_TS">
                                <width value="14.0" unit="d"/>
                            </effectiveTime>
                            <doseQuantity value="50.0" unit="ｍｇ"/>
                            <consumable>
                                <manufacturedProduct>
                                    <manufacturedLabeledDrug>
                                        <code code="100607002" codeSystem="1.2.392.100495.20.2.74" displayName="アレビアチン散１０％"/>
                                    </manufacturedLabeledDrug>
                                </manufacturedProduct>
                            </consumable>
                            <entryRelationship typeCode="REFR" inversionInd="false">
                                <supply classCode="SPLY" moodCode="RQO">
                                    <text></text>
                                    <quantity value="1.4" unit="ｇ"/>
                                </supply>
                            </entryRelationship>
                            <doseCheckQuantity>
                                <numerator value="100.0" unit="ｍｇ">
                                    <translation code="1" codeSystem="1.2.392.100495.20.2.22" displayName="製剤量"/>
                                </numerator>
                                <denominator value="1" unit="d"/>
                            </doseCheckQuantity>
                        </substanceAdministration>
                    </entry>
                    <entry>
                        <substanceAdministration classCode="SBADM" moodCode="RQO">
                            <id root="1.2.392.100495.20.3.81" extension="2"/>
                            <code code="1" codeSystem="1.2.392.100495.20.2.21" displayName="内服" />
                            <effectiveTime operator="A" xsi:type="EIVL_TS">
                                <event code="1012040400000000" codeSystem="1.2.392.100495.20.2.31" displayName="内服・経口・１日２回朝夕食後"/>
                            </effectiveTime>
                            <effectiveTime xsi:type="IVL_TS">
                                <width value="14.0" unit="d"/>
                            </effectiveTime>
                            <doseQuantity value="50.0" unit="ｍｇ"/>
                            <consumable>
                                <manufacturedProduct>
                                    <manufacturedLabeledDrug>
                                        <code code="100565315" codeSystem="1.2.392.100495.20.2.74" displayName="フェノバルビタール散１０％「ホエイ」"/>
                                    </manufacturedLabeledDrug>
                                </manufacturedProduct>
                            </consumable>
                            <entryRelationship typeCode="REFR" inversionInd="false">
                                <supply classCode="SPLY" moodCode="RQO">
                                    <text></text>
                                    <quantity value="1.4" unit="ｇ"/>
                                </supply>
                            </entryRelationship>
                            <doseCheckQuantity>
                                <numerator value="100.0" unit="ｍｇ">
                                    <translation code="1" codeSystem="1.2.392.100495.20.2.22" displayName="製剤量"/>
                                </numerator>
                                <denominator value="1" unit="d"/>
                            </doseCheckQuantity>
                        </substanceAdministration>
                    </entry>                    
                </section>
            </component>
            <component>
                <section>
                    <code code="11" codeSystem="1.2.392.100495.20.2.12"/>
                    <title>保険・公費情報</title>
                    <text>
                        <list>
                            <item>06050116</item>
                            <item>９２０４５</item>
                            <item>１０</item>
                            <item>本人</item>
                            <item>15138092</item>
                            <item>9603283</item>
                        </list>
                    </text>
                    <entry>
                        <act classCode="ACT" moodCode="EVN">
                            <code codeSystem="1.2.392.100495.20.2.64"/>
                            <entryRelationship typeCode="COMP">
                                <act classCode="ACT" moodCode="EVN">
                                    <code code="1" codeSystem="1.2.392.100495.20.2.61" displayName="医保"/>
                                    <performer>
                                        <assignedEntity>
                                            <id root="1.2.392.100495.20.3.61" extension="06050116"/>
                                        </assignedEntity>
                                    </performer>
                                    <participant typeCode="COV">
                                        <participantRole>
                                            <id root="1.2.392.100495.20.3.62" extension="９２０４５"/>
                                            <id root="1.2.392.100495.20.3.63" extension="１０"/>
                                            <code code="1" codeSystem="1.2.392.100495.20.2.62" displayName="被保険者"/>
                                        </participantRole>
                                    </participant>
                                    <entryRelationship typeCode="REFR">
                                        <observation classCode="OBS" moodCode="DEF">
                                            <code code="2" codeSystem="1.2.392.100495.20.2.63" displayName="高齢者７割"/>
                                        </observation>
                                    </entryRelationship>
                                </act>
                            </entryRelationship>
                            <entryRelationship typeCode="COMP">
                                <act classCode="ACT" moodCode="EVN">
                                    <code code="8" codeSystem="1.2.392.100495.20.2.61" displayName="公費"/>
                                    <performer>
                                        <assignedEntity>
                                            <id root="1.2.392.100495.20.3.71" extension="15138092"/>
                                        </assignedEntity>
                                    </performer>
                                    <participant typeCode="COV">
                                        <participantRole>
                                            <id root="1.2.392.100495.20.3.72" extension="9603283"/>
                                        </participantRole>
                                    </participant>
                                </act>
                            </entryRelationship>
                        </act>
                    </entry>
                </section>
            </component>
            <component>
                <section>
                    <code code="101" codeSystem="1.2.392.100495.20.2.12"/>
                    <title>処方箋備考情報</title>
                    <text>
                        <list>
                            <item>調剤上の留意事項</item>
                            <item>麻薬処方時の患者住所・施用者免許番号</item>
                            <item>限度量を超えた投与を行う理由</item>
                            <item>６歳・高一・高７</item>
                            <item>後発医薬品を処方した際に、変更不可とした理由</item>
                            <item>湿布薬の多量投与を判断した趣旨</item>
                            <item>地域包括診療加算等を算定している旨</item>
                            <item>残薬確認時の指示</item>
                        </list>
                    </text>
                </section>
            </component>
            <component>
                <section>
                    <code code="201" codeSystem="1.2.392.100495.20.2.12"/>
                    <title>処方箋補足情報</title>
                    <text>
                        <list>
                            <item>補足情報を項目ごとに箇条書き</item>
                        </list>
                    </text>
                </section>
            </component>
        </structuredBody>
    </component>
</ClinicalDocument>
```

</details>

### test server (heroku)

```
https://fhir-prescription.herokuapp.com/api/hl7/cda_fhir_prescription_generators?format=json
```

### 参考資料
- [電子処方箋CDA記述仕様 第1版](https://www.mhlw.go.jp/content/10800000/000342368.pdf)
- [JAHIS診療文書構造化記述規約共通編Ver.2.0](https://www.jahis.jp/standard/detail/id=729)


## HL7v2 to FHIR

### request
`POST` /api/hl7/v2_fhir_prescription_generators?format=json

| attributes | description |
| :--- | :--- |
| encoding | `ISO-2022-JP` or `UTF-8` |
| prefecture_code | 都道府県コード |
| medical_fee_point_code | 点数表番号 |
| medical_institution_code | 医療機関コード |
| message | Base64エンコードされた `JAHIS処方データ交換規約` 形式のHL7v2メッセージ |

### example

```
{
    "encoding": "ISO-2022-JP",
    "prefecture_code": "13",
    "medical_fee_point_code" : "1",
    "medical_institution_code": "9999999",
    "message": "TVNIfF5+XCZ8SEw3djJ8MTMxOTk5OTk5OXxITDdGSElSfDEzMTk5OTk5OTl8\nMjAxNjA4MjExNjE1MjN8fFJERV5PMTFeUkRFX08xMXwyMDE2MDgyMTE2MTUy\nMzAxNDN8UHwyLjV8fHx8fHx+SVNPSVI4N3x8SVNPIDIwMjItMTk5NApQSUR8\nfHwxMDAwMDAwMDAxXl5eXlBJfHwbJEI0NTxUGyhCXhskQkJATzobKEJeXl5e\nXkxeSX4bJEIlKyVzJTglYxsoQl4bJEIlPyVtJSYbKEJeXl5eXkxeUHx8MTk3\nOTExMDF8TXx8fF5eGyRCPUJDKzZoGyhCXhskQkVsNX5FVBsoQl4xNTEwMDcx\nXkpQTl5IXhskQkVsNX5FVD1CQys2aEtcRC47MEN6TFwjMSMyITwjMRsoQnx8\nXlBSTl5QSF5eXl5eXl5eXjAzLTEyMzQtNTY3OHx8fHx8fHx8fHx8Tnx8fHx8\nfE58fHwyMDE2MTAyODE0MzMwOQpJTjF8MXwwNl4bJEJBSDlnNEk+ODdyOS9K\nXTgxGyhCXkpIU0QwMDAxfDA2MDUwMTE2fHx8fHx8fBskQiM5IzIjMCM0IzUb\nKEJ8GyRCIzEjMBsoQnwxOTk5MDUxNHx8fHx8U0VMXhskQktcP00bKEJeSEw3\nMDA2MwpPUkN8Tld8MTIzNDU2Nzh8fDEyMzQ1Njc4XzAxfHx8fHwyMDE2MDgy\nNXx8fDEyMzQ1Nl4bJEIwZTtVGyhCXhskQj1VO1IbKEJeXl5eXl5eTF5eXl5e\nSX5eGyRCJSQlNxsoQl4bJEIlTyVrJTMbKEJeXl5eXl5eTF5eXl5eUHx8fHx8\nMDFeGyRCRmIyShsoQl45OVowMXx8fHwbJEIlYSVJJWwhPCUvJWolSyVDJS8b\nKEJ8Xl4bJEI5QTZoGyhCXhskQkVsNX5FVBsoQl5eSlBOXl4bJEJFbDV+RVQ5\nQTZoTztLXExaIzMhXSMyIV0jMRsoQnx8fHx8fHxPXhskQjMwTWg0NTxUJSoh\nPCVAGyhCXkhMNzA0ODIKUlhFfHwxMDM4MzU0MDFeGyRCJWAlMyVAJSQlcz57\nIzIjNSMwI20jZxsoQl5IT1R8MXx8VEFCXhskQj57GyhCXk1SOVB8VEFCXhsk\nQj57GyhCXk1SOVB8MDFeGyRCIzEyc0xcJCskaUl+TVEbKEJeSkhTUDAwMDV8\nfHw5fFRBQl4bJEI+exsoQl5NUjlQfHx8fHx8fHwzXlRBQiYbJEI+exsoQiZN\nUjlQfHxPSFBeGyRCMzBNaD1oSn0bKEJeTVI5UH5PSEleGyRCMSFGYj1oSn0b\nKEJeTVI5UHx8fHx8fDIxXhskQkZiSX4bKEJeSkhTUDAwMDMKVFExfHx8MTAx\nMzA0NDQwMDAwMDAwMCYbJEJGYkl+ISY3UDh9ISYjMUZ8IzMyc0QrQ2tNPD8p\nOGUbKEImSkFNSVNEUDAxfHx8M15EJhskQkZ8GyhCJklTTyt8MjAxNjA4MjUK\nUlhSfFBPXhskQjh9GyhCXkhMNzAxNjIKT1JDfE5XfDEyMzQ1Njc4fHwxMjM0\nNTY3OF8wMXx8fHx8MjAxNjA4MjV8fHwxMjM0NTZeGyRCMGU7VRsoQl4bJEI9\nVTtSGyhCXl5eXl5eXkxeXl5eXkl+XhskQiUkJTcbKEJeGyRCJU8layUzGyhC\nXl5eXl5eXkxeXl5eXlB8fHx8fDAxXhskQkZiMkobKEJeOTlaMDF8fHx8GyRC\nJWElSSVsITwlLyVqJUslQyUvGyhCfF5eGyRCOUE2aBsoQl4bJEJFbDV+RVQb\nKEJeXkpQTl5eGyRCRWw1fkVUOUE2aE87S1xMWiMzIV0jMiFdIzEbKEJ8fHx8\nfHx8T14bJEIzME1oNDU8VCUqITwlQBsoQl5ITDcwNDgyClJYRXx8MTEwNjI2\nOTAxXhskQiVRJXMlOSVdJWolcyNUPnsjMSMwIzAbKEIgGyRCIzEjMCMwI20j\nZxsoQl5IT1R8Mnx8VEFCXhskQj57GyhCXk1SOVB8VEFCXhskQj57GyhCXk1S\nOVB8MDFeGyRCIzEyc0xcJCskaUl+TVEbKEJeSkhTUDAwMDV8fHwxOHxUQUJe\nGyRCPnsbKEJeTVI5UHx8fHx8fHx8Nl5UQUImGyRCPnsbKEImTVI5UHx8T0hQ\nXhskQjMwTWg9aEp9GyhCXk1SOVB+T0hJXhskQjEhRmI9aEp9GyhCXk1SOVB8\nfHx8fHwyMV4bJEJGYkl+GyhCXkpIU1AwMDAzClRRMXx8fDEwMTMwNDQ0MDAw\nMDAwMDAmGyRCRmJJfiEmN1A4fSEmIzFGfCMzMnNEK0NrTTw/KThlGyhCJkpB\nTUlTRFAwMXx8fDNeRCYbJEJGfBsoQiZJU08rfDIwMTYwODI1ClJYUnxQT14b\nJEI4fRsoQl5ITDcwMTYyCk9SQ3xOV3wxMjM0NTY3OHx8MTIzNDU2NzhfMDJ8\nfHx8fDIwMTYwODI1fHx8MTIzNDU2XhskQjBlO1UbKEJeGyRCPVU7UhsoQl5e\nXl5eXl5MXl5eXl5Jfl4bJEIlJCU3GyhCXhskQiVPJWslMxsoQl5eXl5eXl5M\nXl5eXl5QfHx8fHwwMV4bJEJGYjJKGyhCXjk5WjAxfHx8fBskQiVhJUklbCE8\nJS8laiVLJUMlLxsoQnxeXhskQjlBNmgbKEJeGyRCRWw1fkVUGyhCXl5KUE5e\nXhskQkVsNX5FVDlBNmhPO0tcTFojMyFdIzIhXSMxGyhCfHx8fHx8fE9eGyRC\nMzBNaDQ1PFQlKiE8JUAbKEJeSEw3MDQ4MgpSWEV8fDEwMDc5NTQwMl4bJEIl\nXCVrJT8lbCVzPnsjMiM1I20jZxsoQl5IT1R8MXx8VEFCXhskQj57GyhCXk1S\nOVB8fHx8fDEwfFRBQl4bJEI+exsoQl5NUjlQfHx8fHx8fHx8fE9IUF4bJEIz\nME1oPWhKfRsoQl5NUjlQfk9ISV4bJEIxIUZiPWhKfRsoQl5NUjlQfHx8fHx8\nMjJeGyRCRlxNURsoQl5KSFNQMDAwMwpUUTF8fHwxMDUwMTEwMDIwMDAwMDAw\nJhskQkZiSX4hJjdQOH0hJmFWREs7fhsoQiZKQU1JU0RQMDF8fHx8MjAxNjA4\nMjV8fHx8MSAbJEJGfBsoQjIgGyRCMnMkXiRHGyhCfHx8MTAKUlhSfFBPXhsk\nQjh9GyhCXkhMNzAxNjIKT1JDfE5XfDEyMzQ1Njc4fHwxMjM0NTY3OF8wM3x8\nfHx8MjAxNjA4MjV8fHwxMjM0NTZeGyRCMGU7VRsoQl4bJEI9VTtSGyhCXl5e\nXl5eXkxeXl5eXkl+XhskQiUkJTcbKEJeGyRCJU8layUzGyhCXl5eXl5eXkxe\nXl5eXlB8fHx8fDAxXhskQkZiMkobKEJeOTlaMDF8fHx8GyRCJWElSSVsITwl\nLyVqJUslQyUvGyhCfF5eGyRCOUE2aBsoQl4bJEJFbDV+RVQbKEJeXkpQTl5e\nGyRCRWw1fkVUOUE2aE87S1xMWiMzIV0jMiFdIzEbKEJ8fHx8fHx8T14bJEIz\nME1oNDU8VCUqITwlQBsoQl5ITDcwNDgyClJYRXx8MTA2MjM4MDAxXhskQiU4\nJVUlaSE8JWtGcDlRIzAhJSMwIzUhcxsoQl5IT1R8IiJ8fCIifE9JVF4bJEJG\ncDlRGyhCXk1SOVB8fHx8MnxIT05eGyRCS1wbKEJeTVI5UHx8fHx8fHx8fHxP\nSFBeGyRCMzBNaD1oSn0bKEJeTVI5UH5PSE9eGyRCMSEzMD1oSn0bKEJeTVI5\nUHx8fHx8fDIzXhskQjMwTVEbKEJeSkhTUDAwMDMKVFExfHx8MkI3NDAwMDAw\nMDAwMDAwMCYbJEIzME1RISZFSUlbISYjMUZ8IzQycxsoQiZKQU1JU0RQMDF8\nfHx8MjAxNjA4MjUKUlhSfEFQXhskQjMwTVEbKEJeSEw3MDE2Mnw3N0xeGyRC\nOjg8ahsoQl5KQU1JU0RQMDEK\n"
}
```

<details><summary>HL7v2(原文)</summary>

```
MSH|^~\&|HL7v2|1319999999|HL7FHIR|1319999999|20160821161523||RDE^O11^RDE_O11|201608211615230143|P|2.5||||||~ISOIR87||ISO 2022-1994
PID|||1000000001^^^^PI||患者^太郎^^^^^L^I~カンジャ^タロウ^^^^^L^P||19791101|M|||^^渋谷区^東京都^1510071^JPN^H^東京都渋谷区本町三丁目１２ー１||^PRN^PH^^^^^^^^^03-1234-5678|||||||||||N||||||N|||20161028143309
IN1|1|06^組合管掌健康保険^JHSD0001|06050116|||||||９２０４５|１０|19990514|||||SEL^本人^HL70063
ORC|NW|12345678||12345678_01|||||20160825|||123456^医師^春子^^^^^^^L^^^^^I~^イシ^ハルコ^^^^^^^L^^^^^P|||||01^内科^99Z01||||メドレークリニック|^^港区^東京都^^JPN^^東京都港区六本木３−２−１|||||||O^外来患者オーダ^HL70482
RXE||103835401^ムコダイン錠２５０ｍｇ^HOT|1||TAB^錠^MR9P|TAB^錠^MR9P|01^１回目から服用^JHSP0005|||9|TAB^錠^MR9P||||||||3^TAB&錠&MR9P||OHP^外来処方^MR9P~OHI^院内処方^MR9P||||||21^内服^JHSP0003
TQ1|||1013044400000000&内服・経口・１日３回朝昼夕食後&JAMISDP01|||3^D&日&ISO+|20160825
RXR|PO^口^HL70162
ORC|NW|12345678||12345678_01|||||20160825|||123456^医師^春子^^^^^^^L^^^^^I~^イシ^ハルコ^^^^^^^L^^^^^P|||||01^内科^99Z01||||メドレークリニック|^^港区^東京都^^JPN^^東京都港区六本木３−２−１|||||||O^外来患者オーダ^HL70482
RXE||110626901^パンスポリンＴ錠１００ １００ｍｇ^HOT|2||TAB^錠^MR9P|TAB^錠^MR9P|01^１回目から服用^JHSP0005|||18|TAB^錠^MR9P||||||||6^TAB&錠&MR9P||OHP^外来処方^MR9P~OHI^院内処方^MR9P||||||21^内服^JHSP0003
TQ1|||1013044400000000&内服・経口・１日３回朝昼夕食後&JAMISDP01|||3^D&日&ISO+|20160825
RXR|PO^口^HL70162
ORC|NW|12345678||12345678_02|||||20160825|||123456^医師^春子^^^^^^^L^^^^^I~^イシ^ハルコ^^^^^^^L^^^^^P|||||01^内科^99Z01||||メドレークリニック|^^港区^東京都^^JPN^^東京都港区六本木３−２−１|||||||O^外来患者オーダ^HL70482
RXE||100795402^ボルタレン錠２５ｍｇ^HOT|1||TAB^錠^MR9P|||||10|TAB^錠^MR9P||||||||||OHP^外来処方^MR9P~OHI^院内処方^MR9P||||||22^頓用^JHSP0003
TQ1|||1050110020000000&内服・経口・疼痛時&JAMISDP01||||20160825||||1 日2 回まで|||10
RXR|PO^口^HL70162
ORC|NW|12345678||12345678_03|||||20160825|||123456^医師^春子^^^^^^^L^^^^^I~^イシ^ハルコ^^^^^^^L^^^^^P|||||01^内科^99Z01||||メドレークリニック|^^港区^東京都^^JPN^^東京都港区六本木３−２−１|||||||O^外来患者オーダ^HL70482
RXE||106238001^ジフラール軟膏０．０５％^HOT|""||""|OIT^軟膏^MR9P||||2|HON^本^MR9P||||||||||OHP^外来処方^MR9P~OHO^院外処方^MR9P||||||23^外用^JHSP0003
TQ1|||2B74000000000000&外用・塗布・１日４回&JAMISDP01||||20160825
RXR|AP^外用^HL70162|77L^左手^JAMISDP01
```

</details>

### test server (heroku)

```
https://fhir-prescription.herokuapp.com/api/hl7/v2_fhir_prescription_generators?format=json
```

### 参考資料
- [JAHIS処方データ交換規約 Ver.3.0C](https://www.jahis.jp/standard/detail/id=564)
- [JAHISデータ交換規約（共通編）Ver.1.2](https://www.jahis.jp/standard/detail/id=725)


## QR-Code to FHIR

### request
`POST` /api/jahis/qr_fhir_prescription_generators?format=json

| attributes | description |
| :--- | :--- |
| encoding | `Shift_JIS` or `UTF-8` |
| qr_code | Base64エンコードされた `JAHIS院外処方箋２次元シンボル記録条件規約` 形式のCSVデータ |

### example

```
{
    "encoding": "Shift_JIS",
    "qr_code": "SkFISVM1CjEsMSwxMjM0NTY3LDEzLIjjl8OWQJBsjtCSY4KYgpmCmonvgUCD\nSYOLg0qDToOKg2qDYoNOCjIsMTEzLTAwMjEsk4yLnpNzlbaLnovmlnuL7o2e\nglE/glGCVz+CUIJVgUCC2YKwgtmCsINyg4uCWIJYgmUKMywwMy0zOTQ2LTAw\nMDEsMDMtMzk0Ni0wMDAyCjQsMiwwMSyT4InICjUsLCyDZYNYg2eI4450CjEx\nLCyL44ifl6yBQInUjnEst62zsbDZIMrFugoxMiwyCjEzLDE5NjcxMDEyCjIx\nLDEKMjIsMDYyNzA0MDkKMjMsLCwxCjI3LDIxMTM2NzkxLDYyNDczNzMKNTEs\nMjAyMDAzMTkKNjEsNjI1MTYsk4yLnpNzkKKTY5JKi+aCUD+CUYJSP4JTglQ/\nglWCVoJXLDAzLTExMTEtMjIyMgoxMDEsMSwxLCwxNAoxMTEsMSwxLCwxk/oz\nifEgloiQSIzjLDMKMjAxLDEsMSwsNywxMTQ5MDE5RjFaWlosgXmUyoF6g42D\nTINcg3aDjYN0g0aDk4JtgoGP+YJVgk+CjYKHLDMsMSyP+QoyODEsMSwxLDEs\nLJXKle8KMjAxLDEsMiwsMywyMzI5MDIxRjEwMjEsg4CDUoNYg16P+SCCUIJP\ngk+CjYKHLDMsMSyP+QoyODEsMSwyLDEsLJXKle8KMTAxLDIsMSwsMTQKMTEx\nLDIsMSwsMZP6MonxIJKpgUWXW5BIjOMsMgoyMDEsMiwxLCwzLDIxNzEwMTRH\nMTAyMCyDQYNfg4mBW4NngmuP+SCCUIJPgo2ChywyLDEsj/kKMjgxLDIsMSwx\nLDIslbKN0woyODEsMiwxLDIsMyyM45StlWmVz41YlXOJwgoxMDEsMywxLCwx\nNAoxMTEsMywxLCwxk/oxifEgl1uQSIzjLDEKMjAxLDMsMSwsMyw4MTE0MDA0\nRzEwMjcsgmyCcoNSg5ODYIOTj/kgglCCT4KNgocsMSwxLI/5CjEwMSw0LDMs\nLDEKMTExLDQsMSwsMZP6MonxIJNclXQsMAoyMDEsNCwxLCwzLDI2NDk4NDNT\nMTAzOSyCbIJyibeDVoNig3aBdYNeg0ODeoNFgXaCUYJPgoeBaYJUloeBXpHc\ngWosMywxLJHcCjEwMSw1LDUsLDEKMTExLDUsMSwsMZP6M4nxIJaIkEiRTyww\nCjIwMSw1LDEsLDMsMjQ5MjQxM0c0MDQwLINtg3uDioOTglGCT4Jxko2DdIOM\ng2KDToNYg3mDkywxLDEsg0yDYoNnCjEwMSw2LDMsLDEKMTExLDYsMSwsMZP6\nM4nxIJNolXosMAoyMDEsNiwxLCwzLDcxMjE3MDNYMTAxMSyUkpBGg4+DWoOK\ng5MsMjAsMSxnCjIwMSw2LDIsLDcsLINPg4qDgYNUg12Dk5PujXAsMzAsMSxn\n"
}
```

<details><summary>QRコード(原文)</summary>

```
JAHIS5
1,1,1234567,13,医療法人社団ｘｙｚ会　オルカクリニック
2,113-0021,東京都文京区本駒込２−２８−１６　ほげほげビル９９Ｆ
3,03-3946-0001,03-3946-0002
4,2,01,内科
5,,,テスト医師
11,,九亜流　花子,ｷｭｳｱｰﾙ ﾊﾅｺ
12,2
13,19671012
21,1
22,06270409
23,,,1
27,21136791,6247373
51,20200319
61,62516,東京都世田谷区１−２３−４５−６７８,03-1111-2222
101,1,1,,14
111,1,1,,1日3回 毎食後,3
201,1,1,,7,1149019F1ZZZ,【般】ロキソプロフェンＮａ錠６０ｍｇ,3,1,錠
281,1,1,1,,別包
201,1,2,,3,2329021F1021,ムコスタ錠 １００ｍｇ,3,1,錠
281,1,2,1,,別包
101,2,1,,14
111,2,1,,1日2回 朝・夕食後,2
201,2,1,,3,2171014G1020,アダラートＬ錠 １０ｍｇ,2,1,錠
281,2,1,1,2,粉砕
281,2,1,2,3,後発品変更不可
101,3,1,,14
111,3,1,,1日1回 夕食後,1
201,3,1,,3,8114004G1027,ＭＳコンチン錠 １０ｍｇ,1,1,錠
101,4,3,,1
111,4,1,,1日2回 貼付,0
201,4,1,,3,2649843S1039,ＭＳ温シップ「タイホウ」２０ｇ（５枚／袋）,3,1,袋
101,5,5,,1
111,5,1,,1日3回 毎食前,0
201,5,1,,3,2492413G4040,ノボリン２０Ｒ注フレックスペン,1,1,キット
101,6,3,,1
111,6,1,,1日3回 塗布,0
201,6,1,,3,7121703X1011,白色ワセリン,20,1,g
201,6,2,,7,,グリメサゾン軟膏,30,1,g
```

</details>

### test server (heroku)

```
https://fhir-prescription.herokuapp.com/api/jahis/qr_fhir_prescription_generators?format=json
```

### 参考資料
- [JAHIS院外処方箋２次元シンボル記録条件規約Ver.1.6](https://www.jahis.jp/standard/detail/id=714)

## ORCA - shohosen to FHIR

### request
`POST` /api/orca/orca_fhir_prescription_generators?format=json

<details><summary>body example</summary>

```
{
  "Information_Date": "2020-10-20",
  "Information_Time": "21:02:27",
  "Api_Result": "0000",
  "Api_Result_Message": "処理終了",
  "Form_ID": "shohosen",
  "Form_Name": "処方箋",
  "Print_Date": "2020-10-20",
  "Print_Time": "21:02:24",
  "Patient": {
    "ID": "00145",
    "Name": "オルカ　三郎",
    "KanaName": "オルカ　サブロウ",
    "BirthDate": "1945-01-01",
    "Sex": "1"
  },
  "Forms": [
    {
      "data": {
        "Form_ID": "shohosen",
        "Printer": "lp1",
        "Order_Class": "0",
        "Perform_Date": "2020-10-20",
        "IssuedDate": "2020-10-20",
        "Department_Code": "01",
        "Department_Name": "内科",
        "EditPageNumber_Flg": "0",
        "Split_Count": "0",
        "Split_Number": "0",
        "Patient": {
          "ID": "00145",
          "Name": "オルカ　三郎",
          "KanaName": "オルカ　サブロウ",
          "BirthDate": "1945-01-01",
          "Sex": "1"
        },
        "Insurance_Combination_Information": {
          "Number": "0004",
          "InsuranceProvider_Class": "039",
          "InsuranceProvider_Name": "後期高齢者",
          "HealthInsuredPerson_Age": "075",
          "HealthInsuredPerson_Rate": "020",
          "HealthInsuredPerson_Rate_Class": "1",
          "Partial_Cost_Payment_Class": "2",
          "HealthInsurance_Information": {
            "InsuranceProvider_Number": "39097001",
            "HealthInsuredPerson_Number": "１２３",
            "HealthInsuredPerson_Assistance": "3",
            "RelationToInsuredPerson": "1",
            "Certificate_StartDate": "2020-10-20",
            "Certificate_ExpiredDate": "9999-12-31"
          },
          "PublicInsurance_Information": [
            {
              "PublicInsurance_Class": "054",
              "PublicInsurance_Name": "難病",
              "PublicInsurer_Number": "54220694",
              "PublicInsuredPerson_Number": "5980610",
              "Certificate_IssuedDate": "2020-10-20",
              "Certificate_ExpiredDate": "9999-12-31"
            },
            {
            },
            {
            },
            {
            }
          ]
        },
        "Hospital": {
          "Prefectures_Number": "13",
          "Code": "1234567",
          "Name": [
            "医療法人　オルカ医院",
            "",
            ""
          ],
          "ZipCode": "1130021",
          "Address": [
            "東京都文京区本駒込２−２８−１６",
            "",
            ""
          ],
          "PhoneNumber": "03-3946-0001",
          "FaxNumber": "03-3946-0002"
        },
        "Doctor": {
          "Code": "10001"
        },
        "Check_Leftover_Class": "1",
        "IncludingNarcotic_Flg": "1",
        "IncludingUnchangeable_Flg": "0",
        "Rp": [
          {
            "Medical_Class": "21",
            "Count": "014",
            "Unit_Name": "日分",
            "Medication": [
              {
                "Name": "ロキソニン錠６０ｍｇ",
                "Amount": "00003.00000",
                "Unit_Name": "錠",
                "Code": "620098801",
                "Generic_Flg": "0",
                "Generic_Code": "1149019F1560"
              },
              {
                "Name": "ＰＬ配合顆粒",
                "Amount": "00003.00000",
                "Unit_Name": "ｇ",
                "Code": "620160501",
                "Generic_Flg": "0",
                "Generic_Code": "1180107D1131"
              },
              {
                "Name": "【１日３回朝昼夕食後】",
                "Code": "001100044",
                "Generic_Flg": "0"
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              }
            ]
          },
          {
            "Medical_Class": "21",
            "Count": "005",
            "Unit_Name": "日分",
            "Medication": [
              {
                "Name": "【般】クラリスロマイシン錠２００ｍｇ",
                "Amount": "00002.00000",
                "Unit_Name": "錠",
                "Code": "616140105",
                "Generic_Flg": "1",
                "Generic_Code": "6149003F2038"
              },
              {
                "Name": "フリーコメント",
                "Code": "810000001",
                "Generic_Flg": "0"
              },
              {
                "Name": "【朝：１．５　夕：０．５】",
                "Code": "001101006",
                "Generic_Flg": "0"
              },
              {
                "Name": "【１日２回朝夕食後】",
                "Code": "001100029",
                "Generic_Flg": "0"
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              }
            ]
          },
          {
            "Medical_Class": "22",
            "Count": "010",
            "Unit_Name": "回分",
            "Medication": [
              {
                "Name": "ＭＳコンチン錠６０ｍｇ",
                "Amount": "00001.00000",
                "Unit_Name": "錠",
                "Code": "610406378",
                "Generic_Flg": "0",
                "Generic_Code": "8114004G3020"
              },
              {
                "Name": "【疼痛時】",
                "Code": "001100071",
                "Generic_Flg": "0"
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              },
              {
              }
            ]
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          },
          {
          }
        ],
        "Memo2": [
          "（高７）",
          "",
          "",
          ""
        ],
        "Memo": [
          "患者住所：東京都港区六本木３−２−１　住友不動産六本木グランドタワー　２２階",
          "麻薬施用者免許証番号：123456",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          ""
        ]
      }
    }
  ]
}
```

</details>

### test server (heroku)

```
https://fhir-prescription.herokuapp.com/api/orca/orca_fhir_prescription_generators?format=json
```

### 参考資料
- [処方せん印刷API](https://www.orca.med.or.jp/receipt/tec/api/report_print/shohosen.html)
