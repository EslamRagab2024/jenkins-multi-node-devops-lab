from flask import Flask, render_template_string

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hybrid CI/CD Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f7f6; text-align: center; padding: 50px; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); display: inline-block; }
        h1 { color: #2c3e50; }
        p { color: #27ae60; font-weight: bold; font-size: 1.2em; }
        .status { background: #e8f8f5; color: #1abc9c; padding: 10px 20px; border-radius: 20px; display: inline-block; }
    </style>
</head>
<body>
    <div class="card">
        <h1> Hybrid CI/CD Pipeline Deployed!</h1>
        <p>Flask Application is running successfully on AWS EC2 Agent.</p>
        <div class="status">● Status: Healthy</div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)