function pm {
  python3 -c "import os.path, $1 as mod
if '__init__.py' in mod.__file__:
  print(os.path.dirname(mod.__file__))
else:
  if mod.__file__.endswith('.pyc') or mod.__file__.endswith('.pyo'):
    print(mod.__file__[:-1])
  else:
    print(mod.__file__)
"
}
function p {
  if [ -z "$(command -v ptpython)" ]; then
    python3 "$@"
  else
    ptpython "$@"
  fi
}
