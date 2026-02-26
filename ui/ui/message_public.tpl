<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>Send Message - BrixNet</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Arial, sans-serif;
            padding: 20px;
        }
        .container { width: 100%; max-width: 600px; }
        .card {
            background: rgba(255,255,255,0.97);
            border-radius: 20px;
            box-shadow: 0 25px 60px rgba(0,0,0,0.4);
            overflow: hidden;
        }
        .card-header {
            background: linear-gradient(135deg, #fb8c00, #e65100);
            padding: 30px;
            text-align: center;
            color: #fff;
        }
        .card-header h1 {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 6px;
        }
        .card-header p {
            font-size: 13px;
            opacity: 0.9;
        }
        .card-body { padding: 30px; }

        /* Alert messages */
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 14px;
        }
        .alert i { margin-top: 2px; flex-shrink: 0; }
        .alert-success {
            background: #e8f5e9;
            border-left: 4px solid #43a047;
            color: #2e7d32;
        }
        .alert-danger {
            background: #fdecea;
            border-left: 4px solid #d32f2f;
            color: #b71c1c;
        }
        .alert-info {
            background: #e3f2fd;
            border-left: 4px solid #1976d2;
            color: #0d47a1;
        }

        /* Form fields */
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #444;
            margin-bottom: 6px;
        }
        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid #dde3ee;
            border-radius: 10px;
            font-size: 14px;
            font-family: inherit;
            color: #222;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            background: #f7f9fc;
        }
        .form-group input:focus,
        .form-group textarea:focus {
            border-color: #fb8c00;
            box-shadow: 0 0 0 3px rgba(251,140,0,0.12);
            background: #fff;
        }
        .form-group textarea {
            resize: vertical;
            min-height: 140px;
        }
        .form-hint {
            font-size: 12px;
            color: #777;
            margin-top: 4px;
        }

        /* Buttons */
        .btn {
            padding: 13px 24px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: opacity 0.2s, transform 0.1s;
        }
        .btn:hover { opacity: 0.92; transform: translateY(-1px); }
        .btn:active { transform: translateY(0); }
        .btn-primary {
            background: linear-gradient(135deg, #fb8c00, #e65100);
            color: #fff;
        }
        .btn-secondary {
            background: #e0e0e0;
            color: #555;
        }
        .btn-block { width: 100%; justify-content: center; }

        .button-group {
            display: flex;
            gap: 12px;
            margin-top: 24px;
        }
        .button-group .btn { flex: 1; }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: #fb8c00;
            text-decoration: none;
            font-size: 14px;
            margin-top: 16px;
        }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="card-header">
                <h1><i class="fas fa-comment-dots"></i> Send Message</h1>
                <p>Tuma Ujumbe kwa Admin / Send a message to admin</p>
            </div>
            <div class="card-body">
                
                {if isset($notify)}
                    {if $notify_t == 's'}
                        <div class="alert alert-success">
                            <i class="fas fa-check-circle"></i>
                            <div>{$notify}</div>
                        </div>
                    {elseif $notify_t == 'e'}
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i>
                            <div>{$notify}</div>
                        </div>
                    {/if}
                {/if}

                <div class="alert alert-info">
                    <i class="fas fa-info-circle"></i>
                    <div>
                        <strong>Need help?</strong> Send us a message and an admin will respond soon.<br>
                        <small>For urgent recharge issues, call: <strong>0745865323</strong> or <strong>0718629152</strong></small>
                    </div>
                </div>

                <form method="post" action="{Text::url('message_public/submit')}">
                    <input type="hidden" name="nux-mac" value="{$mac}">
                    <input type="hidden" name="nux-ip" value="{$ip}">

                    <div class="form-group">
                        <label for="sender_name">
                            <i class="fas fa-user"></i> Your Name / Jina Lako
                            <span style="color: #999; font-weight: 400;">(Optional / Si lazima)</span>
                        </label>
                        <input type="text" id="sender_name" name="sender_name" 
                            placeholder="e.g. John Doe" maxlength="100">
                    </div>

                    <div class="form-group">
                        <label for="sender_contact">
                            <i class="fas fa-phone"></i> Phone Number / Nambari ya Simu
                            <span style="color: #999; font-weight: 400;">(Optional / Si lazima)</span>
                        </label>
                        <input type="text" id="sender_contact" name="sender_contact" 
                            placeholder="e.g. 0712345678" maxlength="50">
                    </div>

                    <div class="form-group">
                        <label for="message">
                            <i class="fas fa-comment"></i> Your Message / Ujumbe Wako
                            <span style="color: #d32f2f;">*</span>
                        </label>
                        <textarea id="message" name="message" required 
                            placeholder="Type your message here... / Andika ujumbe wako hapa..."></textarea>
                        <div class="form-hint">Minimum 10 characters / Angalau herufi 10</div>
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane"></i>
                            Send Message / Tuma
                        </button>
                    </div>
                </form>

                <a href="javascript:history.back()" class="back-link">
                    <i class="fas fa-arrow-left"></i>
                    Back to login / Rudi nyuma
                </a>
            </div>
        </div>
    </div>

    <script>
        // Auto-focus the message field
        document.getElementById('message').focus();
    </script>
</body>
</html>
