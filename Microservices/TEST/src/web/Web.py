import sys
import os

from flask import Flask
from random import randint

# # Get the directory of the current script (Web.py)
# current_dir = os.path.dirname(os.path.abspath(__file__))

# # Construct the path to the 'src' directory, which contains 'tools'
# src_directory = os.path.join(current_dir, "..")

# # Add the 'src' directory to sys.path
# sys.path.append(src_directory)

# # Now you can import 'Calculator.py' from the 'tools' package
# from tools.Calculator import Calculator

from Microservices.TEST.src.tools.Calculator import Calculator

app = Flask(__name__)
my_calculator = Calculator()

@app.route('/')
def hello():
  num1 = randint(0, 100)
  num2 = randint(0, 100)
  message = "Did you know {} + {} = {}?".format(num1, num2, my_calculator.add(num1, num2))
  return message

if __name__ == '__main__':
  app.run(host='0.0.0.0')